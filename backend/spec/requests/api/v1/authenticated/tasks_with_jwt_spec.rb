require 'rails_helper'

RSpec.describe 'Api::V1::Authenticated::Tasks', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:other_project) { create(:project, user: other_user) }

  describe 'GET /api/v1/tasks' do
    let!(:user_task1) { create(:task, project: project, title: 'User Task 1') }
    let!(:user_task2) { create(:task, project: project, title: 'User Task 2', status: :completed) }
    let!(:other_user_task) { create(:task, project: other_project, title: 'Other User Task') }

    context 'with valid authentication' do
      before { get '/api/v1/tasks', headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns only tasks from user projects' do
        expect_json_success
        expect(json_response['data'].size).to eq(2)

        task_titles = json_response['data'].map { |t| t['title'] }
        expect(task_titles).to include('User Task 1', 'User Task 2')
      end
    end

    context 'with project filter' do
      let(:another_project) { create(:project, user: user) }
      let!(:another_task) { create(:task, project: another_project, title: 'Another Task') }

      before { get '/api/v1/tasks', params: { project_id: project.id }, headers: auth_headers(user) }

      it 'filters tasks by project' do
        expect_json_success
        expect(json_response['data'].size).to eq(2)

        task_titles = json_response['data'].map { |t| t['title'] }
        expect(task_titles).to include('User Task 1', 'User Task 2')
        expect(task_titles).not_to include('Another Task')
      end
    end

    context 'with status filter' do
      before { get '/api/v1/tasks', params: { status: 'completed' }, headers: auth_headers(user) }

      it 'filters tasks by status' do
        expect_json_success
        expect(json_response['data'].size).to eq(1)
        expect(json_response['data'].first['title']).to eq('User Task 2')
      end
    end

    context 'without authentication' do
      before { get '/api/v1/tasks' }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/tasks/:id' do
    let!(:task) { create(:task, project: project) }
    let!(:other_user_task) { create(:task, project: other_project) }

    context 'when task belongs to user project' do
      before { get "/api/v1/tasks/#{task.id}", headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the task' do
        expect_json_success
        expect(json_response['data']['id']).to eq(task.id)
      end
    end

    context 'when task does not belong to user project' do
      before { get "/api/v1/tasks/#{other_user_task.id}", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
        expect_json_error('Task not found')
      end
    end
  end

  describe 'POST /api/v1/tasks' do
    let(:valid_params) do
      {
        task: {
          title: 'New Task',
          description: 'Task description',
          status: 'todo',
          priority: 'high',
          project_id: project.id
        }
      }
    end

    context 'with valid authentication and params' do
      it 'creates a new task' do
        expect {
          post '/api/v1/tasks', params: valid_params.to_json, headers: auth_headers(user)
        }.to change(Task, :count).by(1)
      end

      it 'returns created status' do
        post '/api/v1/tasks', params: valid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect_json_success('Task created successfully')
        expect(json_response['data']['title']).to eq('New Task')
      end

      it 'associates task with user and project' do
        post '/api/v1/tasks', params: valid_params.to_json, headers: auth_headers(user)

        created_task = Task.last
        expect(created_task.project).to eq(project)
        expect(created_task.user).to eq(user)
      end
    end

    context 'with assignee' do
      let(:assignee) { create(:user) }
      let(:params_with_assignee) do
        valid_params.deep_merge(task: { user_id: assignee.id })
      end

      it 'assigns task to specified user' do
        post '/api/v1/tasks', params: params_with_assignee.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        created_task = Task.last
        expect(created_task.user).to eq(assignee)
      end
    end

    context 'with project not belonging to user' do
      let(:invalid_params) do
        valid_params.deep_merge(task: { project_id: other_project.id })
      end

      it 'returns unprocessable content' do
        post '/api/v1/tasks', params: invalid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Project not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/tasks', params: valid_params.to_json, headers: { 'Content-Type' => 'application/json' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id' do
    let!(:task) { create(:task, project: project, title: 'Original Title') }
    let(:update_params) { { task: { title: 'Updated Title' } } }

    context 'when task belongs to user project' do
      it 'updates the task' do
        patch "/api/v1/tasks/#{task.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Task updated successfully')
        expect(json_response['data']['title']).to eq('Updated Title')
      end
    end

    context 'when task does not belong to user project' do
      let!(:other_user_task) { create(:task, project: other_project) }

      it 'returns unprocessable content' do
        patch "/api/v1/tasks/#{other_user_task.id}", params: update_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Task not found')
      end
    end
  end

  describe 'DELETE /api/v1/tasks/:id' do
    let!(:task) { create(:task, project: project) }

    context 'when task belongs to user project' do
      it 'deletes the task' do
        expect {
          delete "/api/v1/tasks/#{task.id}", headers: auth_headers(user)
        }.to change(Task, :count).by(-1)
      end

      it 'returns success message' do
        delete "/api/v1/tasks/#{task.id}", headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Task deleted successfully')
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id/complete' do
    let!(:task) { create(:task, project: project, status: :todo) }

    context 'when task belongs to user project' do
      it 'marks task as completed' do
        patch "/api/v1/tasks/#{task.id}/complete", headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Task completed successfully')
        expect(json_response['data']['status']).to eq('completed')
      end

      it 'sets completed_at timestamp' do
        patch "/api/v1/tasks/#{task.id}/complete", headers: auth_headers(user)

        task.reload
        expect(task.completed_at).to be_present
      end
    end

    context 'when task does not belong to user project' do
      let!(:other_user_task) { create(:task, project: other_project) }

      it 'returns unprocessable content' do
        patch "/api/v1/tasks/#{other_user_task.id}/complete", headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect_json_error('Task not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        patch "/api/v1/tasks/#{task.id}/complete"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id/reopen' do
    let!(:task) { create(:task, project: project, status: :completed, completed_at: Time.current) }

    context 'when task belongs to user project' do
      it 'marks task as todo' do
        patch "/api/v1/tasks/#{task.id}/reopen", headers: auth_headers(user)

        expect(response).to have_http_status(:success)
        expect_json_success('Task reopened successfully')
        expect(json_response['data']['status']).to eq('todo')
      end

      it 'clears completed_at timestamp' do
        patch "/api/v1/tasks/#{task.id}/reopen", headers: auth_headers(user)

        task.reload
        expect(task.completed_at).to be_nil
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        patch "/api/v1/tasks/#{task.id}/reopen"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
