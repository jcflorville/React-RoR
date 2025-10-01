require 'rails_helper'

RSpec.describe 'Api::V1::Authenticated::Projects', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/v1/projects' do
    let!(:user_project1) { create(:project, user: user, name: 'User Project 1') }
    let!(:user_project2) { create(:project, user: user, name: 'User Project 2') }
    let!(:other_user_project) { create(:project, user: other_user) }

    context 'with valid authentication' do
      before { get '/api/v1/projects', headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns only user projects' do
        expect_json_success
        expect(json_response['data'].size).to eq(2)

        project_names = json_response['data'].map { |p| p['name'] }
        expect(project_names).to include('User Project 1', 'User Project 2')
      end

      it 'includes project attributes' do
        project_data = json_response['data'].first
        expect(project_data).to include(
          'id', 'name', 'description', 'status', 'priority',
          'start_date', 'end_date', 'created_at', 'updated_at'
        )
      end
    end

    context 'with search parameter' do
      before { get '/api/v1/projects', params: { search: 'Project 1' }, headers: auth_headers(user) }

      it 'filters projects by search term' do
        expect_json_success
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['name']).to eq('User Project 1')
      end
    end

    context 'with status filter' do
      let!(:completed_project) { create(:project, user: user, status: :completed) }

      before { get '/api/v1/projects', params: { status: 'completed' }, headers: auth_headers(user) }

      it 'filters projects by status' do
        expect_json_success
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['status']).to eq('completed')
      end
    end

    context 'with sorting' do
      before { get '/api/v1/projects', params: { sort: 'name_asc' }, headers: auth_headers(user) }

      it 'sorts projects correctly' do
        expect_json_success
        project_names = json_response['data'].map { |p| p['name'] }
        expect(project_names).to eq(project_names.sort)
      end
    end

    context 'without authentication' do
      before { get '/api/v1/projects' }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid token' do
      before do
        get '/api/v1/projects', headers: { 'Authorization' => 'Bearer invalid_token' }
      end

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/projects/:id' do
    let!(:project) { create(:project, user: user) }
    let!(:other_user_project) { create(:project, user: other_user) }

    context 'when project belongs to user' do
      before { get "/api/v1/projects/#{project.id}", headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the project' do
        expect_json_success
        expect(json_response['data']['id']).to eq(project.id)
        expect(json_response['data']['name']).to eq(project.name)
      end
    end

    context 'when project does not belong to user' do
      before { get "/api/v1/projects/#{other_user_project.id}", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
        expect_json_error('Project not found')
      end
    end

    context 'without authentication' do
      before { get "/api/v1/projects/#{project.id}" }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/projects' do
    let(:valid_params) do
      {
        project: {
          name: 'New Project',
          description: 'Project description',
          status: 'active',
          priority: 'high'
        }
      }
    end

    context 'with valid authentication and params' do
      it 'creates a new project' do
        expect {
          post '/api/v1/projects', params: valid_params.to_json, headers: auth_headers(user)
        }.to change(Project, :count).by(1)
      end

      it 'returns created status' do
        post '/api/v1/projects', params: valid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect_json_success('Project created successfully')
        expect(json_response['data']['name']).to eq('New Project')
      end

      it 'associates project with authenticated user' do
        post '/api/v1/projects', params: valid_params.to_json, headers: auth_headers(user)

        created_project = Project.last
        expect(created_project.user).to eq(user)
      end
    end

    context 'with categories' do
      let!(:category1) { create(:category) }
      let!(:category2) { create(:category) }
      let(:params_with_categories) do
        valid_params.deep_merge(project: { category_ids: [ category1.id, category2.id ] })
      end

      it 'associates categories with project' do
        post '/api/v1/projects', params: params_with_categories.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        created_project = Project.last
        expect(created_project.categories).to include(category1, category2)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { project: { name: '' } } }

      it 'returns unprocessable content' do
        post '/api/v1/projects', params: invalid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Failed to create project')
        expect(json_response['errors']).to be_present
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/projects', params: valid_params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    let!(:project) { create(:project, user: user, name: 'Original Name') }
    let(:update_params) { { project: { name: 'Updated Name' } } }

    context 'when project belongs to user' do
      it 'updates the project' do
        patch "/api/v1/projects/#{project.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Project updated successfully')
        expect(json_response['data']['name']).to eq('Updated Name')
      end

      it 'persists the changes' do
        patch "/api/v1/projects/#{project.id}", params: update_params.to_json, headers: auth_headers(user)

        project.reload
        expect(project.name).to eq('Updated Name')
      end
    end

    context 'when project does not belong to user' do
      let!(:other_user_project) { create(:project, user: other_user) }

      it 'returns unprocessable content' do
        patch "/api/v1/projects/#{other_user_project.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Project not found')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { project: { name: '' } } }

      it 'returns validation errors' do
        patch "/api/v1/projects/#{project.id}", params: invalid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Failed to update project')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        patch "/api/v1/projects/#{project.id}", params: update_params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/projects/:id' do
    let!(:project) { create(:project, user: user) }

    context 'when project belongs to user' do
      it 'deletes the project' do
        expect {
          delete "/api/v1/projects/#{project.id}", headers: auth_headers(user)
        }.to change(Project, :count).by(-1)
      end

      it 'returns success message' do
        delete "/api/v1/projects/#{project.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Project deleted successfully')
      end
    end

    context 'when project does not belong to user' do
      let!(:other_user_project) { create(:project, user: other_user) }

      it 'does not delete the project' do
        expect {
          delete "/api/v1/projects/#{other_user_project.id}", headers: auth_headers(user)
        }.not_to change(Project, :count)
      end

      it 'returns error' do
        delete "/api/v1/projects/#{other_user_project.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Project not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        delete "/api/v1/projects/#{project.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
