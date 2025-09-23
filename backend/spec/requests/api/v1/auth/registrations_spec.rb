require 'rails_helper'

RSpec.describe 'API::V1::Auth::Registrations', type: :request do
  describe 'POST /api/v1/auth/sign_up' do
    let(:valid_params) do
      {
        user: attributes_for(:user)
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/auth/sign_up', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns success status' do
        post '/api/v1/auth/sign_up', params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns JWT token in Authorization header' do
        post '/api/v1/auth/sign_up', params: valid_params
        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end

      it 'returns user data' do
        post '/api/v1/auth/sign_up', params: valid_params
        json_response = response.parsed_body
        expect(json_response['data']).to be_present
        expect(json_response['data']['email']).to eq(valid_params[:user][:email])
      end

      it 'returns user id in response' do
        post '/api/v1/auth/sign_up', params: valid_params
        json_response = response.parsed_body
        expect(json_response['data']['id']).to be_present
      end

      it 'does not return password in response' do
        post '/api/v1/auth/sign_up', params: valid_params
        json_response = response.parsed_body
        expect(json_response['data']).not_to have_key('password')
        expect(json_response['data']).not_to have_key('password_digest')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a user with invalid email' do
        invalid_params = valid_params.dup
        invalid_params[:user][:email] = 'invalid_email'

        expect {
          post '/api/v1/auth/sign_up', params: invalid_params
        }.not_to change(User, :count)
      end

      it 'returns error for duplicate email' do
        create(:user, email: 'test@example.com')
        duplicate_params = { user: attributes_for(:user, email: 'test@example.com') }
        post '/api/v1/auth/sign_up', params: duplicate_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns error messages' do
        invalid_params = { user: { email: 'invalid_email' } }
        post '/api/v1/auth/sign_up', params: invalid_params

        json_response = response.parsed_body
        expect(json_response['errors']).to be_present
      end

      it 'returns error for missing email' do
        invalid_params = { user: { password: 'password123' } }
        post '/api/v1/auth/sign_up', params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response['errors']['email']).to be_present
      end

      it 'returns error for missing password' do
        invalid_params = { user: { email: 'test@example.com' } }
        post '/api/v1/auth/sign_up', params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response['errors']['password']).to be_present
      end

      it 'returns error for weak password' do
        invalid_params = { user: { email: 'test@example.com', password: '123' } }
        post '/api/v1/auth/sign_up', params: invalid_params

        expect(response).to have_http_status(:unprocessable_content)
        json_response = response.parsed_body
        expect(json_response['errors']['password']).to be_present
      end

      it 'does not return token on error' do
        invalid_params = { user: { email: 'invalid_email' } }
        post '/api/v1/auth/sign_up', params: invalid_params

        json_response = response.parsed_body
        expect(json_response['token']).to be_nil
        expect(response.headers['Authorization']).to be_nil
      end
    end
  end
end
