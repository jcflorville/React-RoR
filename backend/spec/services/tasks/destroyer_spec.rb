# spec/services/tasks/destroyer_spec.rb
require 'rails_helper'

RSpec.describe Tasks::Destroyer, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let!(:task) { create(:task, project: project) }
    let!(:other_task) { create(:task, project: create(:project, user: other_user)) }

    context 'with valid task' do
      it 'destroys task successfully' do
        expect {
          result = described_class.call(user: user, task_id: task.id)
          expect(result.success?).to be true
          expect(result.message).to eq('Task deleted successfully')
        }.to change(Task, :count).by(-1)
      end

      it 'destroys task with comments' do
        create(:comment, task: task, user: user)

        expect {
          result = described_class.call(user: user, task_id: task.id)
          expect(result.success?).to be true
        }.to change(Task, :count).by(-1).and change(Comment, :count).by(-1)
      end
    end

    context 'with invalid task' do
      it 'fails when task does not belong to user' do
        result = described_class.call(user: user, task_id: other_task.id)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
        expect(Task.exists?(other_task.id)).to be true
      end

      it 'fails when task does not exist' do
        result = described_class.call(user: user, task_id: 99999)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end
    end
  end
end
