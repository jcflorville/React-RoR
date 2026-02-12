require 'rails_helper'

RSpec.describe 'Api::V1::Authenticated::Drawings', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/v1/drawings' do
    let!(:user_drawing1) { create(:drawing, user: user, title: 'My First Drawing') }
    let!(:user_drawing2) { create(:drawing, user: user, title: 'My Second Drawing') }
    let!(:other_user_drawing) { create(:drawing, user: other_user) }

    context 'with valid authentication' do
      before { get '/api/v1/drawings', headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns only user drawings' do
        expect_json_success
        expect(json_response['data'].size).to eq(2)
        drawing_titles = json_response['data'].map { |d| d['title'] }
        expect(drawing_titles).to include('My First Drawing', 'My Second Drawing')
      end

      it 'includes all drawing attributes' do
        drawing_data = json_response['data'].first
        expect(drawing_data).to include(
          'id', 'title', 'canvas_data', 'lock_version',
          'created_at', 'updated_at'
        )
      end
    end

    context 'without authentication' do
      before { get '/api/v1/drawings' }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/drawings/:id' do
    let!(:drawing) { create(:drawing, user: user, title: 'Test Drawing') }

    context 'with valid authentication' do
      before { get "/api/v1/drawings/#{drawing.id}", headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the drawing' do
        expect_json_success
        expect(json_response['data']['id']).to eq(drawing.id)
        expect(json_response['data']['title']).to eq('Test Drawing')
      end

      it 'includes canvas_data structure' do
        expect(json_response['data']['canvas_data']).to include('version', 'objects', 'background')
      end
    end

    context 'accessing another user drawing' do
      before { get "/api/v1/drawings/#{drawing.id}", headers: auth_headers(other_user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/drawings' do
    context 'with valid parameters' do
      let(:valid_params) do
        { drawing: { title: 'New Drawing' } }
      end

      before { post '/api/v1/drawings', params: valid_params.to_json, headers: auth_headers(user) }

      it 'creates a new drawing' do
        expect(response).to have_http_status(:created)
        expect_json_success
        expect(json_response['data']['title']).to eq('New Drawing')
        expect(json_response['data']['lock_version']).to eq(0)
      end

      it 'sets default canvas_data' do
        expect(json_response['data']['canvas_data']).to include(
          'version' => '5.3.0',
          'objects' => [],
          'background' => '#ffffff'
        )
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        { drawing: { title: 'a' * 300 } }
      end

      before { post '/api/v1/drawings', params: invalid_params.to_json, headers: auth_headers(user) }

      it 'returns unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PATCH /api/v1/drawings/:id' do
    let!(:drawing) { create(:drawing, user: user, title: 'Original Title') }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          drawing: {
            title: 'Updated Title',
            lock_version: drawing.lock_version
          }
        }
      end

      before { patch "/api/v1/drawings/#{drawing.id}", params: valid_params.to_json, headers: auth_headers(user) }

      it 'updates the drawing' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']['title']).to eq('Updated Title')
        expect(json_response['data']['lock_version']).to eq(1)
      end
    end

    context 'with canvas_data update' do
      let(:new_canvas_data) do
        {
          version: '5.3.0',
          objects: [ { type: 'path', points: [ [ 0, 0 ], [ 10, 10 ] ] } ],
          background: '#ffffff'
        }
      end

      let(:params_with_canvas) do
        {
          drawing: {
            canvas_data: new_canvas_data,
            lock_version: drawing.lock_version
          }
        }
      end

      before { patch "/api/v1/drawings/#{drawing.id}", params: params_with_canvas.to_json, headers: auth_headers(user) }

      it 'updates canvas_data' do
        expect(response).to have_http_status(:success)
        expect(json_response['data']['canvas_data']['objects']).to be_present
      end
    end

    context 'with lock_version mismatch' do
      let(:params_with_old_version) do
        {
          drawing: {
            title: 'Updated Title',
            lock_version: 999
          }
        }
      end

      before { patch "/api/v1/drawings/#{drawing.id}", params: params_with_old_version.to_json, headers: auth_headers(user) }

      it 'returns unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['message']).to include('modified by another user')
      end
    end
  end

  describe 'DELETE /api/v1/drawings/:id' do
    let!(:drawing) { create(:drawing, user: user) }

    context 'with valid authentication' do
      it 'deletes the drawing' do
        expect {
          delete "/api/v1/drawings/#{drawing.id}", headers: auth_headers(user)
        }.to change(Drawing, :count).by(-1)

        expect(response).to have_http_status(:success)
      end
    end

    context 'accessing another user drawing' do
      before { delete "/api/v1/drawings/#{drawing.id}", headers: auth_headers(other_user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
