# spec/services/tasks/finder_spec.rb
require 'rails_helper'

RSpec.describe Tasks::Finder, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:other_project) { create(:project, user: other_user) }

    let!(:user_task1) { create(:task, project: project, title: 'User Task 1', status: :todo) }
    let!(:user_task2) { create(:task, project: project, title: 'User Task 2', status: :completed) }
    let!(:other_task) { create(:task, project: other_project, title: 'Other Task') }

    context 'finding all user tasks' do
      it 'returns only user tasks' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        expect(result.data).to include(user_task1, user_task2)
        expect(result.data).not_to include(other_task)
      end
    end

    context 'finding specific task by id' do
      it 'returns the task when it belongs to user' do
        result = described_class.call(user: user, params: { id: user_task1.id })

        expect(result.success?).to be true
        expect(result.data).to eq(user_task1)
      end

      it 'fails when task does not belong to user' do
        result = described_class.call(user: user, params: { id: other_task.id })

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end

      it 'fails when task does not exist' do
        result = described_class.call(user: user, params: { id: 99999 })

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end
    end

    context 'filtering by status' do
      it 'filters tasks by status' do
        result = described_class.call(user: user, params: { status: 'todo' })

        expect(result.success?).to be true
        expect(result.data).to include(user_task1)
        expect(result.data).not_to include(user_task2)
      end
    end

    context 'searching tasks' do
      it 'searches tasks by title' do
        result = described_class.call(user: user, params: { search: 'Task 1' })

        expect(result.success?).to be true
        expect(result.data).to include(user_task1)
        expect(result.data).not_to include(user_task2)
      end
    end

    context 'sorting tasks' do
      it 'sorts tasks by created_at asc by default' do
        result = described_class.call(user: user, params: {})

        expect(result.success?).to be true
        # Default ordering is by created_at ascending (oldest first)
        expect(result.data.first.created_at).to be <= result.data.last.created_at
      end
    end
  end
end
