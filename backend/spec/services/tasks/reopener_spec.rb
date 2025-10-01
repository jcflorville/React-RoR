# spec/services/tasks/reopener_spec.rb
require 'rails_helper'

RSpec.describe Tasks::Reopener, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let!(:completed_task) { create(:task, project: project, status: :completed, completed_at: 1.day.ago) }
    let!(:other_task) { create(:task, project: create(:project, user: other_user)) }

    context 'with valid task' do
      it 'reopens completed task successfully' do
        result = described_class.call(user: user, task_id: completed_task.id)

        expect(result.success?).to be true
        expect(result.data.status).to eq('todo')
        expect(result.data.completed_at).to be_nil
        expect(result.message).to eq('Task reopened successfully')
      end

      it 'can reopen already todo task' do
        todo_task = create(:task, project: project, status: :todo)
        result = described_class.call(user: user, task_id: todo_task.id)

        expect(result.success?).to be true
        expect(result.data.status).to eq('todo')
        expect(result.data.completed_at).to be_nil
      end

      it 'clears completed_at timestamp' do
        result = described_class.call(user: user, task_id: completed_task.id)

        expect(result.success?).to be true
        expect(result.data.completed_at).to be_nil
      end
    end

    context 'with invalid task' do
      it 'fails when task does not belong to user' do
        result = described_class.call(user: user, task_id: other_task.id)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end

      it 'fails when task does not exist' do
        result = described_class.call(user: user, task_id: 99999)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end
    end
  end
end
