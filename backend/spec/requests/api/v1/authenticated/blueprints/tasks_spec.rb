require 'rails_helper'

RSpec.describe 'TaskBlueprint Serialization', type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let!(:task) do
    create(:task,
      project: project,
      user: user,
      title: 'Implement feature',
      description: 'Add new feature to the app',
      status: 'in_progress',
      priority: 'high',
      due_date: 3.days.from_now
    )
  end

  describe 'GET /api/v1/tasks - TaskBlueprint index' do
    before { get '/api/v1/tasks', headers: auth_headers(user) }

    context 'response structure' do
      it 'returns success response format' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']).to be_an(Array)
      end

      it 'includes task basic attributes' do
        task_data = json_response['data'].first

        expect(task_data).to include(
          'id' => task.id,
          'title' => 'Implement feature',
          'description' => 'Add new feature to the app',
          'status' => 'in_progress',
          'priority' => 'high'
        )
      end

      it 'includes computed attributes' do
        task_data = json_response['data'].first

        expect(task_data).to have_key('overdue')
        expect(task_data).to have_key('days_until_due')
        expect(task_data['overdue']).to be_in([ true, false ])
        expect(task_data['days_until_due']).to be_a(Integer)
      end

      it 'includes timestamps' do
        task_data = json_response['data'].first

        expect(task_data).to include(
          'due_date',
          'created_at',
          'updated_at'
        )
      end

      it 'includes completed_at when applicable' do
        task_data = json_response['data'].first
        expect(task_data).to have_key('completed_at')
      end
    end

    context 'data types' do
      it 'returns correct data types for each field' do
        task_data = json_response['data'].first

        expect(task_data['id']).to be_an(Integer)
        expect(task_data['title']).to be_a(String)
        expect(task_data['description']).to be_a(String)
        expect(task_data['status']).to be_a(String)
        expect(task_data['priority']).to be_a(String)
        expect(task_data['overdue']).to be_in([ true, false ])
        expect(task_data['days_until_due']).to be_an(Integer)
      end
    end
  end

  describe 'GET /api/v1/tasks/:id - TaskBlueprint show' do
    before { get "/api/v1/tasks/#{task.id}", headers: auth_headers(user) }

    it 'returns single task with correct structure' do
      expect(response).to have_http_status(:success)
      expect_json_success

      task_data = json_response['data']
      expect(task_data).to be_a(Hash)
      expect(task_data['id']).to eq(task.id)
      expect(task_data['title']).to eq('Implement feature')
    end
  end

  describe 'POST /api/v1/tasks - TaskBlueprint create' do
    let(:task_params) do
      {
        task: {
          title: 'New Task',
          description: 'Task description',
          status: 'todo',
          priority: 'medium',
          project_id: project.id,
          due_date: 5.days.from_now
        }
      }
    end

    before { post '/api/v1/tasks', params: task_params.to_json, headers: auth_headers(user) }

    it 'returns created task with TaskBlueprint' do
      expect(response).to have_http_status(:created)
      expect_json_success

      task_data = json_response['data']
      expect(task_data['title']).to eq('New Task')
      expect(task_data['status']).to eq('todo')
      expect(task_data['priority']).to eq('medium')
    end

    it 'includes computed fields in created task' do
      task_data = json_response['data']

      expect(task_data).to have_key('overdue')
      expect(task_data).to have_key('days_until_due')
      expect(task_data['overdue']).to eq(false) # New task in future
      expect(task_data['days_until_due']).to be > 0
    end
  end

  describe 'computed fields accuracy' do
    context 'when task is overdue' do
      let!(:overdue_task) do
        create(:task,
          project: project,
          user: user,
          title: 'Overdue Task',
          due_date: 2.days.ago,
          status: 'in_progress'
        )
      end

      before { get '/api/v1/tasks', headers: auth_headers(user) }

      it 'correctly identifies overdue status' do
        overdue_task_data = json_response['data'].find { |t| t['title'] == 'Overdue Task' }

        expect(overdue_task_data['overdue']).to eq(true)
        expect(overdue_task_data['days_until_due']).to be < 0
      end
    end

    context 'when task is completed' do
      let!(:completed_task) do
        create(:task,
          project: project,
          user: user,
          title: 'Completed Task',
          status: 'completed',
          completed_at: 1.day.ago
        )
      end

      before { get '/api/v1/tasks', headers: auth_headers(user) }

      it 'includes completed_at timestamp' do
        completed_task_data = json_response['data'].find { |t| t['title'] == 'Completed Task' }

        expect(completed_task_data['completed_at']).not_to be_nil
        expect(completed_task_data['status']).to eq('completed')
      end
    end
  end
end
