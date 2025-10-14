require 'rails_helper'

RSpec.describe 'Api::V1::Authenticated::Projects::Tasks', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:other_user_project) { create(:project, user: other_user) }

  describe 'GET /api/v1/projects/:project_id/tasks' do
    let!(:task1) { create(:task, project: project, user: user, title: 'Task 1', status: :todo, priority: :high) }
    let!(:task2) { create(:task, project: project, user: user, title: 'Task 2', status: :in_progress, priority: :medium) }
    let!(:other_project_task) { create(:task, project: other_user_project, user: other_user) }

    context 'with valid authentication' do
      before { get "/api/v1/projects/#{project.id}/tasks", headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns only tasks from the specified project' do
        expect_json_success
        expect(json_response['data'].size).to eq(2)

        task_titles = json_response['data'].map { |t| t['title'] }
        expect(task_titles).to include('Task 1', 'Task 2')
      end

      it 'includes all task attributes' do
        task_data = json_response['data'].first
        expect(task_data).to include(
          'id', 'title', 'description', 'status', 'priority',
          'due_date', 'completed_at', 'overdue', 'days_until_due',
          'created_at', 'updated_at'
        )
      end

      it 'follows ApiResponse success format' do
        expect(json_response).to include('success', 'data')
        expect(json_response['success']).to be true
        expect(json_response['data']).to be_an(Array)
      end
    end

    context 'with filters' do
      context 'by status' do
        before { get "/api/v1/projects/#{project.id}/tasks", params: { status: 'todo' }, headers: auth_headers(user) }

        it 'filters tasks by status' do
          expect_json_success
          expect(json_response['data'].size).to eq(1)
          expect(json_response['data'].first['status']).to eq('todo')
        end
      end

      context 'by priority' do
        before { get "/api/v1/projects/#{project.id}/tasks", params: { priority: 'high' }, headers: auth_headers(user) }

        it 'filters tasks by priority' do
          expect_json_success
          expect(json_response['data'].size).to eq(1)
          expect(json_response['data'].first['priority']).to eq('high')
        end
      end
    end

    context 'when project does not belong to user' do
      before { get "/api/v1/projects/#{other_user_project.id}/tasks", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without authentication' do
      before { get "/api/v1/projects/#{project.id}/tasks" }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/projects/:project_id/tasks/:id' do
    let!(:task) { create(:task, project: project, user: user, title: 'Test Task') }
    let!(:other_task) { create(:task, project: other_user_project, user: other_user) }

    context 'when task belongs to user project' do
      before { get "/api/v1/projects/#{project.id}/tasks/#{task.id}", headers: auth_headers(user) }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the task with all attributes' do
        expect_json_success
        expect(json_response['data']['title']).to eq('Test Task')
        expect(json_response['data']).to include('id', 'title', 'description', 'status', 'priority')
      end
    end

    context 'when task does not belong to user project' do
      before { get "/api/v1/projects/#{other_user_project.id}/tasks/#{other_task.id}", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when task does not exist' do
      before { get "/api/v1/projects/#{project.id}/tasks/99999", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/projects/:project_id/tasks' do
    let(:valid_attributes) do
      {
        task: {
          title: 'New Task',
          description: 'Task description',
          status: 'todo',
          priority: 'medium',
          due_date: 1.week.from_now.to_date
        }
      }
    end

    let(:invalid_attributes) do
      {
        task: {
          title: ''
        }
      }
    end

    context 'with valid attributes' do
      before do
        post "/api/v1/projects/#{project.id}/tasks",
             params: valid_attributes.to_json,
             headers: auth_headers(user)
      end

      it 'returns http created' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a new task' do
        expect {
          post "/api/v1/projects/#{project.id}/tasks",
               params: valid_attributes.to_json,
               headers: auth_headers(user)
        }.to change(Task, :count).by(1)
      end

      it 'returns the created task' do
        expect_json_success
        expect(json_response['data']['title']).to eq('New Task')
        expect(json_response['data']['description']).to eq('Task description')
      end

      it 'associates task with the project' do
        task = Task.last
        expect(task.project_id).to eq(project.id)
      end

      it 'associates task with the user' do
        task = Task.last
        expect(task.user_id).to eq(user.id)
      end
    end

    context 'with invalid attributes' do
      before do
        post "/api/v1/projects/#{project.id}/tasks",
             params: invalid_attributes.to_json,
             headers: auth_headers(user)
      end

      it 'returns unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not create a task' do
        expect {
          post "/api/v1/projects/#{project.id}/tasks",
               params: invalid_attributes.to_json,
               headers: auth_headers(user)
        }.not_to change(Task, :count)
      end

      it 'returns error messages' do
        expect(json_response['success']).to be false
        expect(json_response).to have_key('errors')
      end
    end

    context 'when project does not belong to user' do
      before do
        post "/api/v1/projects/#{other_user_project.id}/tasks",
             params: valid_attributes.to_json,
             headers: auth_headers(user)
      end

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/tasks/:id' do
    let!(:task) { create(:task, project: project, user: user, title: 'Original Title') }

    let(:valid_attributes) do
      {
        task: {
          title: 'Updated Title',
          description: 'Updated description'
        }
      }
    end

    let(:invalid_attributes) do
      {
        task: {
          title: ''
        }
      }
    end

    context 'with valid attributes' do
      before do
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
              params: valid_attributes.to_json,
              headers: auth_headers(user)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates the task' do
        task.reload
        expect(task.title).to eq('Updated Title')
        expect(task.description).to eq('Updated description')
      end

      it 'returns the updated task' do
        expect_json_success
        expect(json_response['data']['title']).to eq('Updated Title')
      end
    end

    context 'with invalid attributes' do
      before do
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}",
              params: invalid_attributes.to_json,
              headers: auth_headers(user)
      end

      it 'returns unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'does not update the task' do
        task.reload
        expect(task.title).to eq('Original Title')
      end
    end

    context 'when task does not belong to user project' do
      let!(:other_task) { create(:task, project: other_user_project, user: other_user) }

      before do
        patch "/api/v1/projects/#{other_user_project.id}/tasks/#{other_task.id}",
              params: valid_attributes.to_json,
              headers: auth_headers(user)
      end

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/projects/:project_id/tasks/:id' do
    let!(:task) { create(:task, project: project, user: user) }

    context 'when task belongs to user project' do
      it 'deletes the task' do
        expect {
          delete "/api/v1/projects/#{project.id}/tasks/#{task.id}", headers: auth_headers(user)
        }.to change(Task, :count).by(-1)
      end

      it 'returns success' do
        delete "/api/v1/projects/#{project.id}/tasks/#{task.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:success)
        expect_json_success
      end
    end

    context 'when task does not belong to user project' do
      let!(:other_task) { create(:task, project: other_user_project, user: other_user) }

      before do
        delete "/api/v1/projects/#{other_user_project.id}/tasks/#{other_task.id}",
               headers: auth_headers(user)
      end

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'does not delete the task' do
        expect(Task.exists?(other_task.id)).to be true
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/tasks/:id/complete' do
    let!(:task) { create(:task, project: project, user: user, status: :in_progress) }

    context 'when completing a task' do
      before do
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}/complete",
              headers: auth_headers(user)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'marks the task as completed' do
        task.reload
        expect(task.status).to eq('completed')
        expect(task.completed_at).not_to be_nil
      end

      it 'returns the updated task' do
        expect_json_success
        expect(json_response['data']['status']).to eq('completed')
      end
    end

    context 'when task does not belong to user project' do
      let!(:other_task) { create(:task, project: other_user_project, user: other_user) }

      before do
        patch "/api/v1/projects/#{other_user_project.id}/tasks/#{other_task.id}/complete",
              headers: auth_headers(user)
      end

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/projects/:project_id/tasks/:id/reopen' do
    let!(:task) { create(:task, project: project, user: user, status: :completed, completed_at: Time.current) }

    context 'when reopening a task' do
      before do
        patch "/api/v1/projects/#{project.id}/tasks/#{task.id}/reopen",
              headers: auth_headers(user)
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'marks the task as todo' do
        task.reload
        expect(task.status).to eq('todo')
        expect(task.completed_at).to be_nil
      end

      it 'returns the updated task' do
        expect_json_success
        expect(json_response['data']['status']).to eq('todo')
      end
    end

    context 'when task does not belong to user project' do
      let!(:other_task) { create(:task, project: other_user_project, user: other_user, status: :completed) }

      before do
        patch "/api/v1/projects/#{other_user_project.id}/tasks/#{other_task.id}/reopen",
              headers: auth_headers(user)
      end

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
