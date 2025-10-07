require 'rails_helper'

RSpec.describe 'Api::V1::Authenticated::Projects', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/v1/projects' do
    let!(:user_project1) { create(:project, user: user, name: 'User Project 1', status: :active, priority: :high) }
    let!(:user_project2) { create(:project, user: user, name: 'User Project 2', status: :draft, priority: :medium) }
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

      it 'includes all project attributes' do
        project_data = json_response['data'].first
        expect(project_data).to include(
          'id', 'name', 'description', 'status', 'priority',
          'start_date', 'end_date', 'created_at', 'updated_at'
        )
      end

      it 'returns projects with correct data types' do
        project_data = json_response['data'].first
        expect(project_data['id']).to be_an(Integer)
        expect(project_data['name']).to be_a(String)
        expect(project_data['status']).to be_a(String)
        expect(project_data['priority']).to be_a(String)
      end

      it 'follows ApiResponse success format' do
        expect(json_response).to include('success', 'data')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_an(Array)
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

    context 'with priority filter' do
      before { get '/api/v1/projects', params: { priority: 'high' }, headers: auth_headers(user) }

      it 'filters projects by priority' do
        expect_json_success
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['priority']).to eq('high')
      end
    end

    context 'with multiple filters' do
      before do
        get '/api/v1/projects',
            params: { status: 'active', priority: 'high' },
            headers: auth_headers(user)
      end

      it 'applies multiple filters correctly' do
        expect_json_success
        expect(json_response['data'].size).to eq(1)
        project = json_response['data'].first
        expect(project['status']).to eq('active')
        expect(project['priority']).to eq('high')
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

    context 'with empty results' do
      let(:empty_user) { create(:user) }

      before { get '/api/v1/projects', headers: auth_headers(empty_user) }

      it 'returns empty array when user has no projects' do
        expect_json_success
        expect(json_response['data']).to eq([])
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
    let!(:project) { create(:project, user: user, name: 'Test Project', description: 'Test Description') }
    let!(:other_user_project) { create(:project, user: other_user) }

    context 'when project belongs to user' do
      before { get "/api/v1/projects/#{project.id}", headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the project with all attributes' do
        expect_json_success
        expect(json_response['data']['id']).to eq(project.id)
        expect(json_response['data']['name']).to eq('Test Project')
        expect(json_response['data']['description']).to eq('Test Description')
      end

      it 'follows ApiResponse success format for single resource' do
        expect(json_response).to include('success', 'data')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_a(Hash)
      end

      it 'includes all expected attributes' do
        project_data = json_response['data']
        expected_attributes = %w[id name description status priority start_date end_date created_at updated_at]
        expect(project_data.keys).to include(*expected_attributes)
      end
    end

    context 'when project does not belong to user' do
      before { get "/api/v1/projects/#{other_user_project.id}", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
        expect_json_error('Project not found')
      end

      it 'follows ApiResponse error format' do
        expect(json_response).to include('success', 'message')
        expect(json_response['success']).to be false
      end
    end

    context 'when project does not exist' do
      before { get "/api/v1/projects/99999", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
        expect_json_error('Project not found')
      end
    end

    context 'with invalid project id format' do
      before { get "/api/v1/projects/invalid_id", headers: auth_headers(user) }

      it 'returns not found or bad request' do
        # Rails typically converts invalid IDs to not found
        expect(response.status).to be_in([ 400, 404 ])
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
          priority: 'high',
          start_date: Date.current,
          end_date: 1.month.from_now.to_date
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

      it 'follows ApiResponse success format for creation' do
        post '/api/v1/projects', params: valid_params.to_json, headers: auth_headers(user)

        expect(json_response).to include('success', 'data', 'message')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_a(Hash)
        expect(json_response['message']).to eq('Project created successfully')
      end

      it 'returns all project attributes in response' do
        post '/api/v1/projects', params: valid_params.to_json, headers: auth_headers(user)

        project_data = json_response['data']
        expect(project_data).to include('id', 'name', 'description', 'status', 'priority')
        expect(project_data['name']).to eq('New Project')
        expect(project_data['description']).to eq('Project description')
        expect(project_data['status']).to eq('active')
        expect(project_data['priority']).to eq('high')
      end
    end

    context 'with minimal valid params' do
      let(:minimal_params) { { project: { name: 'Minimal Project' } } }

      it 'creates project with defaults' do
        post '/api/v1/projects', params: minimal_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect(json_response['data']['name']).to eq('Minimal Project')
        expect(json_response['data']['status']).to eq('draft') # default status
        expect(json_response['data']['priority']).to eq('medium') # default priority
      end
    end

    context 'with categories' do
      let!(:category1) { create(:category, name: 'Development') }
      let!(:category2) { create(:category, name: 'Testing') }
      let(:params_with_categories) do
        valid_params.deep_merge(project: { category_ids: [ category1.id, category2.id ] })
      end

      it 'associates categories with project' do
        post '/api/v1/projects', params: params_with_categories.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        created_project = Project.last
        expect(created_project.categories).to include(category1, category2)
      end

      it 'ignores non-existent category IDs' do
        params_with_invalid = valid_params.deep_merge(project: { category_ids: [ 99999 ] })

        post '/api/v1/projects', params: params_with_invalid.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect(Project.last.categories).to be_empty
      end
    end

    context 'with invalid params' do
      context 'missing required fields' do
        let(:invalid_params) { { project: { description: 'No name provided' } } }

        it 'returns unprocessable content with validation errors' do
          post '/api/v1/projects', params: invalid_params.to_json, headers: auth_headers(user)

          expect(response).to have_http_status(:unprocessable_content)
          expect_json_error('Failed to create project')
          expect(json_response['errors']).to be_present
          expect(json_response['errors']['name']).to be_present
        end
      end

      context 'name too short' do
        let(:invalid_params) { { project: { name: 'x' } } }

        it 'returns validation error for name length' do
          post '/api/v1/projects', params: invalid_params.to_json, headers: auth_headers(user)

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response['errors']['name']).to include('is too short (minimum is 2 characters)')
        end
      end

      context 'name too long' do
        let(:invalid_params) { { project: { name: 'a' * 101 } } }

        it 'returns validation error for name length' do
          post '/api/v1/projects', params: invalid_params.to_json, headers: auth_headers(user)

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response['errors']['name']).to include('is too long (maximum is 100 characters)')
        end
      end

      # TODO: Implementar teste de validação de datas quando o Updater for desenvolvido
      # The Creator currently does not process start_date and end_date (uses model defaults)
      # context 'invalid date range' do
      #   let(:invalid_params) do
      #     {
      #       project: {
      #         name: 'Invalid Project',
      #         start_date: Date.current,
      #         end_date: Date.current - 1.day
      #       }
      #     }
      #   end

      #   it 'returns validation error for date range' do
      #     post '/api/v1/projects', params: invalid_params.to_json, headers: auth_headers(user)

      #     expect(response).to have_http_status(:unprocessable_content)
      #     expect(json_response['errors']['end_date']).to include('deve ser posterior à data de início')
      #   end
      # end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/projects', params: valid_params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a project' do
        expect {
          post '/api/v1/projects', params: valid_params.to_json, headers: { 'Content-Type' => 'application/json' }
        }.not_to change(Project, :count)
      end
    end
  end

  describe 'PATCH /api/v1/projects/:id' do
    let!(:project) { create(:project, user: user, name: 'Original Name', description: 'Original Description') }
    let(:update_params) { { project: { name: 'Updated Name', description: 'Updated Description' } } }

    context 'when project belongs to user' do
      it 'updates the project' do
        patch "/api/v1/projects/#{project.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Project updated successfully')
        expect(json_response['data']['name']).to eq('Updated Name')
        expect(json_response['data']['description']).to eq('Updated Description')
      end

      it 'persists the changes' do
        patch "/api/v1/projects/#{project.id}", params: update_params.to_json, headers: auth_headers(user)

        project.reload
        expect(project.name).to eq('Updated Name')
        expect(project.description).to eq('Updated Description')
      end

      it 'follows ApiResponse success format for updates' do
        patch "/api/v1/projects/#{project.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(json_response).to include('success', 'data', 'message')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_a(Hash)
        expect(json_response['message']).to eq('Project updated successfully')
      end

      it 'allows partial updates' do
        partial_params = { project: { name: 'Only Name Updated' } }

        patch "/api/v1/projects/#{project.id}", params: partial_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect(json_response['data']['name']).to eq('Only Name Updated')
        expect(json_response['data']['description']).to eq('Original Description') # unchanged
      end

      it 'updates status and priority' do
        status_params = { project: { status: 'completed', priority: 'urgent' } }

        patch "/api/v1/projects/#{project.id}", params: status_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect(json_response['data']['status']).to eq('completed')
        expect(json_response['data']['priority']).to eq('urgent')
      end
    end

    context 'when project does not belong to user' do
      let!(:other_user_project) { create(:project, user: other_user) }

      it 'returns unprocessable content' do
        patch "/api/v1/projects/#{other_user_project.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Project not found')
      end

      it 'does not update the project' do
        original_name = other_user_project.name

        patch "/api/v1/projects/#{other_user_project.id}", params: update_params.to_json, headers: auth_headers(user)

        other_user_project.reload
        expect(other_user_project.name).to eq(original_name)
      end
    end

    context 'with invalid params' do
      context 'empty name' do
        let(:invalid_params) { { project: { name: '' } } }

        it 'returns validation errors' do
          patch "/api/v1/projects/#{project.id}", params: invalid_params.to_json, headers: auth_headers(user)

          expect(response).to have_http_status(:unprocessable_content)
          expect_json_error('Failed to update project')
          expect(json_response['errors']['name']).to be_present
        end
      end

      context 'name too short' do
        let(:invalid_params) { { project: { name: 'x' } } }

        it 'returns validation error for name length' do
          patch "/api/v1/projects/#{project.id}", params: invalid_params.to_json, headers: auth_headers(user)

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response['errors']['name']).to include('is too short (minimum is 2 characters)')
        end
      end

      context 'invalid date range' do
        let(:invalid_params) do
          {
            project: {
              start_date: Date.current,
              end_date: Date.current - 1.day
            }
          }
        end

        it 'returns validation error for date range' do
          patch "/api/v1/projects/#{project.id}", params: invalid_params.to_json, headers: auth_headers(user)

          expect(response).to have_http_status(:unprocessable_content)
          expect(json_response['errors']['end_date']).to include('deve ser posterior à data de início')
        end
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

      it 'follows ApiResponse success format for deletion' do
        delete "/api/v1/projects/#{project.id}", headers: auth_headers(user)

        expect(json_response).to include('success', 'message')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_nil
        expect(json_response['message']).to eq('Project deleted successfully')
      end

      it 'actually removes the project from database' do
        project_id = project.id
        delete "/api/v1/projects/#{project_id}", headers: auth_headers(user)

        expect(Project.find_by(id: project_id)).to be_nil
      end
    end

    context 'when project has associated tasks' do
      let!(:task) { create(:task, project: project) }

      it 'deletes project and associated tasks (cascade)' do
        expect {
          delete "/api/v1/projects/#{project.id}", headers: auth_headers(user)
        }.to change(Project, :count).by(-1).and change(Task, :count).by(-1)
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

    context 'when project does not exist' do
      it 'returns error for non-existent project' do
        delete "/api/v1/projects/99999", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Project not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        delete "/api/v1/projects/#{project.id}"

        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not delete the project' do
        expect {
          delete "/api/v1/projects/#{project.id}"
        }.not_to change(Project, :count)
      end
    end
  end
end
