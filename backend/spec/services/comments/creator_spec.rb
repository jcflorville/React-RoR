# spec/services/comments/creator_spec.rb
require 'rails_helper'

RSpec.describe Comments::Creator, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:task) { create(:task, project: project) }
    let(:other_task) { create(:task, project: create(:project, user: other_user)) }

    let(:valid_params) do
      {
        content: 'This is a test comment',
        task_id: task.id
      }
    end

    context 'with valid parameters' do
      it 'creates comment successfully' do
        result = described_class.call(user: user, params: valid_params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Comment)
        expect(result.data.content).to eq('This is a test comment')
        expect(result.data.task).to eq(task)
        expect(result.data.user).to eq(user)
        expect(result.message).to eq('Comment created successfully')
      end

      it 'creates comment with correct associations' do
        result = described_class.call(user: user, params: valid_params)

        expect(result.success?).to be true
        expect(result.data.task.project.user).to eq(user)
      end
    end

    context 'with invalid parameters' do
      it 'fails when content is missing' do
        invalid_params = valid_params.except(:content)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to create comment')
        expect(result.errors[:content]).to be_present
      end

      it 'fails when task does not exist' do
        invalid_params = valid_params.merge(task_id: 99999)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end

      it 'fails when task does not belong to user projects' do
        invalid_params = valid_params.merge(task_id: other_task.id)
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.message).to eq('Task not found')
      end

      it 'fails when content is too short' do
        invalid_params = valid_params.merge(content: '')
        result = described_class.call(user: user, params: invalid_params)

        expect(result.success?).to be false
        expect(result.errors[:content]).to be_present
      end
    end
  end
end
