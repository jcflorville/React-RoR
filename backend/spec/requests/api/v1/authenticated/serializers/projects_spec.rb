require 'rails_helper'

RSpec.describe 'Projects API Serialization', type: :request do
  let(:user) { create(:user) }
  let(:category1) { create(:category, name: 'Frontend') }
  let(:category2) { create(:category, name: 'Backend') }

  describe 'GET /api/v1/projects (index) - serialization' do
    let!(:project) do
      create(:project,
        user: user,
        name: 'Test Project',
        description: 'A test project',
        status: 'active',
        priority: 'high',
        categories: [ category1, category2 ]
      )
    end
    let!(:task1) { create(:task, project: project, title: 'Task 1', status: 'todo') }
    let!(:task2) { create(:task, project: project, title: 'Task 2', status: 'in_progress') }

    before { get '/api/v1/projects', headers: auth_headers(user) }

    context 'response structure' do
      it 'returns success response format' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']).to be_an(Array)
      end

      it 'includes project basic attributes' do
        project_data = json_response['data'].first

        expect(project_data).to include(
          'id' => project.id,
          'name' => 'Test Project',
          'description' => 'A test project',
          'status' => 'active',
          'priority' => 'high'
        )
      end

      it 'includes computed attributes' do
        project_data = json_response['data'].first

        expect(project_data).to include(
          'progress_percentage',
          'overdue',
          'status_humanized',
          'priority_humanized'
        )
      end

      it 'includes timestamps' do
        project_data = json_response['data'].first

        expect(project_data).to include(
          'created_at',
          'updated_at'
        )
      end
    end

    # context 'when project has no tasks or categories' do
    #   let!(:empty_project) { create(:project, user: user, name: 'Empty Project') }

    #   it 'includes empty arrays for tasks and categories' do
    #     project_data = json_response['data'].find { |p| p['name'] == 'Empty Project' }

    #     expect(project_data['tasks']).to eq([])
    #     expect(project_data['categories']).to eq([])
    #   end
    # end
  end

  describe 'GET /api/v1/projects/:id (show) - serialization' do
    let!(:project) do
      create(:project,
        user: user,
        name: 'Single Project',
        description: 'A single project test',
        status: 'draft',
        priority: 'medium',
        categories: [ category1 ]
      )
    end
    let!(:task1) { create(:task, project: project, title: 'Show Task 1', status: 'todo') }
    let!(:task2) { create(:task, project: project, title: 'Show Task 2', status: 'completed') }

    before { get "/api/v1/projects/#{project.id}?include=tasks,categories", headers: auth_headers(user) }

    context 'response structure' do
      it 'returns success response format' do
        expect(response).to have_http_status(:success)
        expect_json_success
        expect(json_response['data']).to be_a(Hash)
      end

      it 'includes project basic attributes' do
        project_data = json_response['data']

        expect(project_data).to include(
          'id' => project.id,
          'name' => 'Single Project',
          'description' => 'A single project test',
          'status' => 'draft',
          'priority' => 'medium'
        )
      end
    end

    context 'tasks serialization in show action' do
      it 'includes tasks in the response' do
        project_data = json_response['data']

        expect(project_data).to have_key('tasks')
        expect(project_data['tasks']).to be_an(Array)
      end

      it 'includes all project tasks' do
        project_data = json_response['data']
        tasks_data = project_data['tasks']

        expect(tasks_data.size).to eq(2)
      end

      it 'includes correct task data for show action' do
        project_data = json_response['data']
        tasks_data = project_data['tasks']
        task_titles = tasks_data.map { |t| t['title'] }

        expect(task_titles).to match_array([ 'Show Task 1', 'Show Task 2' ])
      end
    end

    context 'categories serialization in show action' do
      it 'includes categories in the response' do
        project_data = json_response['data']

        expect(project_data).to have_key('categories')
        expect(project_data['categories']).to be_an(Array)
      end

      it 'includes all project categories' do
        project_data = json_response['data']
        categories_data = project_data['categories']

        expect(categories_data.size).to eq(1)
      end

      it 'includes correct category data for show action' do
        project_data = json_response['data']
        categories_data = project_data['categories']

        expect(categories_data.first['name']).to eq('Frontend')
      end
    end
  end

  # describe 'serialization edge cases' do
  #   context 'when relationships are not properly loaded' do
  #     let!(:project) { create(:project, user: user, name: 'Edge Case Project') }
  #     let!(:task) { create(:task, project: project, title: 'Edge Case Task') }

  #     before { get '/api/v1/projects', headers: auth_headers(user) }

  #     it 'should not cause N+1 queries or missing data' do
  #       project_data = json_response['data'].first

  #       # Se o eager loading não estiver funcionando, tasks pode não aparecer
  #       # ou gerar N+1 queries. Este teste deve falhar se o bug existir.
  #       expect(project_data).to have_key('tasks')

  #       # Deve incluir as tasks mesmo se o eager loading não estiver perfeito
  #       expect(project_data['tasks']).to be_an(Array)
  #     end
  #   end

  #   context 'multiple projects with different amounts of tasks/categories' do
  #     let!(:project1) do
  #       create(:project, user: user, name: 'Project 1', categories: [ category1 ])
  #     end
  #     let!(:project2) do
  #       create(:project, user: user, name: 'Project 2', categories: [ category1, category2 ])
  #     end
  #     let!(:task1) { create(:task, project: project1, title: 'P1 Task') }
  #     let!(:task2) { create(:task, project: project2, title: 'P2 Task 1') }
  #     let!(:task3) { create(:task, project: project2, title: 'P2 Task 2') }

  #     before { get '/api/v1/projects', headers: auth_headers(user) }

  #     it 'serializes each project with correct number of relationships' do
  #       projects_data = json_response['data']

  #       project1_data = projects_data.find { |p| p['name'] == 'Project 1' }
  #       project2_data = projects_data.find { |p| p['name'] == 'Project 2' }

  #       expect(project1_data['tasks'].size).to eq(1)
  #       expect(project1_data['categories'].size).to eq(1)

  #       expect(project2_data['tasks'].size).to eq(2)
  #       expect(project2_data['categories'].size).to eq(2)
  #     end
  #   end
  # end
end
