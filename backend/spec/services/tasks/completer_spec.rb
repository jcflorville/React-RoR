# spec/services/tasks/completer_spec.rb
require 'rails_helper'

RSpec.describe Tasks::Completer, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let!(:task) { create(:task, project: project, status: :todo) }
    let!(:other_task) { create(:task, project: create(:project, user: other_user)) }

    context 'with valid task' do
      it 'marks task as completed successfully' do
        result = described_class.call(user: user, task_id: task.id)

        expect(result.success?).to be true
        expect(result.data.status).to eq('completed')
        expect(result.data.completed_at).to be_within(1.second).of(Time.current)
        expect(result.message).to eq('Task completed successfully')
      end

      it 'can complete already completed task' do
        completed_task = create(:task, project: project, status: :completed)
        result = described_class.call(user: user, task_id: completed_task.id)

        expect(result.success?).to be true
        expect(result.data.status).to eq('completed')
      end

      it 'updates completed_at timestamp' do
        before_time = Time.current
        result = described_class.call(user: user, task_id: task.id)
        after_time = Time.current

        expect(result.success?).to be true
        expect(result.data.completed_at).to be_between(before_time, after_time)
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
