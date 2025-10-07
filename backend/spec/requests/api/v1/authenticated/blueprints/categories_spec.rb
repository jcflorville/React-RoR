require 'rails_helper'

RSpec.describe 'CategoryBlueprint Serialization', type: :request do
  let(:user) { create(:user) }
  let!(:category) do
    create(:category,
      name: 'Frontend',
      color: '#3B82F6',
      description: 'Frontend development tasks'
    )
  end

  describe 'GET /api/v1/categories - CategoryBlueprint index' do
    before { get '/api/v1/categories', headers: auth_headers(user) }

    context 'response structure' do
      it 'returns success response format' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']).to be_an(Array)
      end

      it 'includes category basic attributes' do
        category_data = json_response['data'].first

        expect(category_data).to include(
          'id' => category.id,
          'name' => 'Frontend',
          'color' => '#3B82F6',
          'description' => 'Frontend development tasks'
        )
      end

      it 'includes timestamps' do
        category_data = json_response['data'].first

        expect(category_data).to include(
          'created_at',
          'updated_at'
        )
      end
    end

    context 'data types' do
      it 'returns correct data types for each field' do
        category_data = json_response['data'].first

        expect(category_data['id']).to be_an(Integer)
        expect(category_data['name']).to be_a(String)
        expect(category_data['color']).to be_a(String)
        expect(category_data['description']).to be_a(String)
        expect(category_data['created_at']).to be_a(String)
        expect(category_data['updated_at']).to be_a(String)
      end
    end

    context 'when category has no description' do
      let!(:minimal_category) { create(:category, name: 'Backend', description: nil) }

      before { get '/api/v1/categories', headers: auth_headers(user) }

      it 'includes null for description' do
        backend_category = json_response['data'].find { |c| c['name'] == 'Backend' }
        expect(backend_category).to be_present
        expect(backend_category['description']).to be_nil
      end
    end
  end

  describe 'GET /api/v1/categories/:id - CategoryBlueprint show' do
    before { get "/api/v1/categories/#{category.id}", headers: auth_headers(user) }

    it 'returns single category with correct structure' do
      expect(response).to have_http_status(:success)
      expect_json_success

      category_data = json_response['data']
      expect(category_data).to be_a(Hash)
      expect(category_data['id']).to eq(category.id)
      expect(category_data['name']).to eq('Frontend')
    end
  end

  describe 'POST /api/v1/categories - CategoryBlueprint create' do
    let(:category_params) do
      {
        category: {
          name: 'Design',
          color: '#EC4899',
          description: 'Design and UX tasks'
        }
      }
    end

    before { post '/api/v1/categories', params: category_params.to_json, headers: auth_headers(user) }

    it 'returns created category with CategoryBlueprint' do
      expect(response).to have_http_status(:created)
      expect_json_success

      category_data = json_response['data']
      expect(category_data['name']).to eq('Design')
      expect(category_data['color']).to eq('#EC4899')
      expect(category_data['description']).to eq('Design and UX tasks')
    end
  end
end
