# spec/services/tasks/updater_spec.rb
require 'rails_helper'

RSpec.describe Tasks::Updater, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:task) { create(:task, project: project, title: 'Original Title') }
    let(:other_task) { create(:task, project: create(:project, user: other_user)) }

    let(:update_params) do
      {
        title: 'Updated Title',
        description: 'Updated Description',
        priority: 'high'
      }
    end

    context 'with valid parameters' do
      it 'updates task successfully' do
        result = described_class.call(user: user, task_id: task.id, params: update_params)

        expect(result.success?).to be true
        expect(result.data.title).to eq('Updated Title')
        expect(result.data.description).to eq('Updated Description')
        expect(result.data.priority).to eq('high')
        expect(result.message).to eq('Task updated successfully')
      end

      it 'updates assignee when user_id provided' do
        new_assignee = create(:user)
        params_with_assignee = update_params.merge(user_id: new_assignee.id)

        result = described_class.call(user: user, task_id: task.id, params: params_with_assignee)

        expect(result.success?).to be true
        expect(result.data.user).to eq(new_assignee)
      end

      it 'partially updates task' do
        partial_params = { title: 'New Title Only' }
        result = described_class.call(user: user, task_id: task.id, params: partial_params)

        expect(result.success?).to be true
        expect(result.data.title).to eq('New Title Only')
        expect(result.data.description).to eq(task.description) # unchanged
      end
    end

    context 'with invalid parameters' do
      it 'fails when task does not belong to user' do
        result = described_class.call(user: user, task_id: other_task.id, params: update_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end

      it 'fails when task does not exist' do
        result = described_class.call(user: user, task_id: 99999, params: update_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end

      it 'fails with invalid title' do
        invalid_params = update_params.merge(title: '')
        result = described_class.call(user: user, task_id: task.id, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to update task')
        expect(result.errors[:title]).to be_present
      end

      it 'fails when new assignee does not exist' do
        invalid_params = update_params.merge(user_id: 99999)
        result = described_class.call(user: user, task_id: task.id, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Assignee not found')
      end
    end

    context 'edge cases' do
      it 'handles empty params gracefully' do
        result = described_class.call(user: user, task_id: task.id, params: {})

        expect(result.success?).to be true
        expect(result.data.title).to eq(task.title) # unchanged
      end
    end
  end
end
