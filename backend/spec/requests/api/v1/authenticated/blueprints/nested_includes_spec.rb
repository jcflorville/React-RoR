require 'rails_helper'

RSpec.describe 'Nested Includes in Blueprints', type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user, name: 'Test Project') }
  let(:task) { create(:task, project: project, user: user, title: 'Test Task') }
  let!(:comment1) { create(:comment, task: task, user: user, content: 'First comment') }
  let!(:comment2) { create(:comment, task: task, user: user, content: 'Second comment') }
  let!(:category) { create(:category, name: 'Backend') }

  before do
    project.categories << category
  end

  describe 'GET /api/v1/projects/:id with nested includes' do
    context 'with ?include=tasks.comments,categories' do
      before do
        get "/api/v1/projects/#{project.id}?include=tasks.comments,categories",
          headers: auth_headers(user)
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
        expect_json_success
      end

      it 'includes project data' do
        project_data = json_response['data']
        expect(project_data['name']).to eq('Test Project')
      end

      it 'includes tasks' do
        project_data = json_response['data']
        expect(project_data).to have_key('tasks')
        expect(project_data['tasks']).to be_an(Array)
        expect(project_data['tasks'].first['title']).to eq('Test Task')
      end

      it 'includes nested comments in tasks' do
        project_data = json_response['data']
        task_data = project_data['tasks'].first

        expect(task_data).to have_key('comments')
        expect(task_data['comments']).to be_an(Array)
        expect(task_data['comments'].size).to eq(2)

        comment_contents = task_data['comments'].map { |c| c['content'] }
        expect(comment_contents).to match_array([ 'First comment', 'Second comment' ])
      end

      it 'includes categories' do
        project_data = json_response['data']
        expect(project_data).to have_key('categories')
        expect(project_data['categories']).to be_an(Array)
        expect(project_data['categories'].first['name']).to eq('Backend')
      end
    end

    context 'with ?include=tasks (without nested comments)' do
      before do
        get "/api/v1/projects/#{project.id}?include=tasks",
          headers: auth_headers(user)
      end

      it 'includes tasks but NOT comments' do
        project_data = json_response['data']
        task_data = project_data['tasks'].first

        expect(task_data['title']).to eq('Test Task')
        expect(task_data).not_to have_key('comments')
      end
    end

    context 'without include parameter' do
      before do
        get "/api/v1/projects/#{project.id}",
          headers: auth_headers(user)
      end

      it 'does not include tasks or categories' do
        project_data = json_response['data']

        expect(project_data).not_to have_key('tasks')
        expect(project_data).not_to have_key('categories')
      end
    end
  end

  describe 'parsing nested includes' do
    it 'parses simple includes' do
      params = { include: 'tasks,categories' }
      includes = params[:include].split(',').flat_map do |inc|
        inc.strip.split('.').map(&:to_sym)
      end.uniq

      expect(includes).to eq([ :tasks, :categories ])
    end

    it 'parses nested includes' do
      params = { include: 'tasks.comments,categories' }
      includes = params[:include].split(',').flat_map do |inc|
        inc.strip.split('.').map(&:to_sym)
      end.uniq

      expect(includes).to eq([ :tasks, :comments, :categories ])
    end

    it 'parses multiple nested includes' do
      params = { include: 'tasks.comments.user,categories' }
      includes = params[:include].split(',').flat_map do |inc|
        inc.strip.split('.').map(&:to_sym)
      end.uniq

      expect(includes).to eq([ :tasks, :comments, :user, :categories ])
    end
  end
end
