# spec/services/tasks/creator_spec.rb
require 'rails_helper'

RSpec.describe Tasks::Creator, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:assignee) { create(:user) }

    let(:valid_params) do
      {
        project_id: project.id,
        title: 'Test Task',
        description: 'Test Description',
        priority: 'high',
        due_date: 1.week.from_now,
        user_id: assignee.id
      }
    end

    context 'with valid parameters' do
      it 'creates a task successfully' do
        result = described_class.call(user: user, params: valid_params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Task)
        expect(result.data.title).to eq('Test Task')
        expect(result.data.project).to eq(project)
        expect(result.data.user).to eq(assignee)
        expect(result.message).to eq('Task created successfully')
      end

      it 'creates a task with correct attributes' do
        result = described_class.call(user: user, params: valid_params)
        task = result.data

        expect(task.title).to eq('Test Task')
        expect(task.description).to eq('Test Description')
        expect(task.priority).to eq('high')
        expect(task.status).to eq('todo')
        expect(task.due_date).to be_within(1.second).of(1.week.from_now)
      end

      it 'assigns task to user when user_id provided' do
        result = described_class.call(user: user, params: valid_params)

        expect(result.data.user).to eq(assignee)
      end

      it 'assigns task to project owner when no user_id provided' do
        params_without_assignee = valid_params.except(:user_id)
        result = described_class.call(user: user, params: params_without_assignee)

        expect(result.data.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'fails when project does not exist' do
        invalid_params = valid_params.merge(project_id: 99999)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Project not found')
      end

      it 'fails when project does not belong to user' do
        other_user = create(:user)
        other_project = create(:project, user: other_user)
        invalid_params = valid_params.merge(project_id: other_project.id)

        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Project not found')
      end

      it 'fails when title is missing' do
        invalid_params = valid_params.except(:title)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to create task')
        expect(result.errors[:title]).to be_present
      end

      it 'fails when title is too short' do
        invalid_params = valid_params.merge(title: 'x')
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:title]).to be_present
      end

      it 'falls back to current user when assignee does not exist' do
        invalid_params = valid_params.merge(user_id: 99999)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be true
        expect(result.data.user).to eq(user) # fallback to current user
      end
    end

    context 'edge cases' do
      it 'handles nil due_date gracefully' do
        params_without_due_date = valid_params.except(:due_date)
        result = described_class.call(user: user, params: params_without_due_date)

        expect(result.success?).to be true
        expect(result.data.due_date).to be_nil
      end

      it 'handles empty description' do
        params_without_description = valid_params.except(:description)
        result = described_class.call(user: user, params: params_without_description)

        expect(result.success?).to be true
        expect(result.data.description).to be_nil
      end
    end
  end
end
