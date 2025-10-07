require 'rails_helper'

RSpec.describe 'UserBlueprint Serialization', type: :request do
  let(:user) { create(:user, name: 'Test User', email: 'test@example.com') }

  describe 'GET /api/v1/profiles - UserBlueprint' do
    before { get '/api/v1/profiles', headers: auth_headers(user) }

    context 'response structure' do
      it 'returns success response format' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']).to be_a(Hash)
      end

      it 'includes user basic attributes' do
        user_data = json_response['data']

        expect(user_data).to include(
          'id' => user.id,
          'name' => 'Test User',
          'email' => 'test@example.com'
        )
      end

      it 'includes timestamps' do
        user_data = json_response['data']

        expect(user_data).to include(
          'created_at',
          'updated_at'
        )
      end

      it 'does not include sensitive data' do
        user_data = json_response['data']

        expect(user_data).not_to have_key('password')
        expect(user_data).not_to have_key('encrypted_password')
        expect(user_data).not_to have_key('password_digest')
      end
    end

    context 'data types' do
      it 'returns correct data types for each field' do
        user_data = json_response['data']

        expect(user_data['id']).to be_an(Integer)
        expect(user_data['name']).to be_a(String)
        expect(user_data['email']).to be_a(String)
        expect(user_data['created_at']).to be_a(String)
        expect(user_data['updated_at']).to be_a(String)
      end
    end
  end

  describe 'PATCH /api/v1/profiles - UserBlueprint update' do
    let(:update_params) { { user: { name: 'Updated Name' } } }

    before { patch '/api/v1/profiles', params: update_params.to_json, headers: auth_headers(user) }

    it 'returns updated user data with UserBlueprint' do
      expect(response).to have_http_status(:success)
      expect_json_success

      user_data = json_response['data']
      expect(user_data['name']).to eq('Updated Name')
      expect(user_data['email']).to eq('test@example.com')
    end
  end
end
