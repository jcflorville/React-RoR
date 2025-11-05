require 'rails_helper'

RSpec.describe Notifications::Creator, type: :service do
  describe '.call' do
    let(:recipient) { create(:user, name: 'John') }
    let(:actor) { create(:user, name: 'Jane') }
    let(:project) { create(:project, user: recipient) }
    let(:task) { create(:task, project: project, user: recipient) }

    let(:valid_params) do
      {
        recipient: recipient,
        actor: actor,
        notifiable: task,
        event_type: :task_assigned,
        metadata: { task_title: task.title, project_id: project.id }
      }
    end

    context 'with valid parameters' do
      it 'creates notification successfully' do
        result = described_class.call(**valid_params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Notification)
        expect(result.data.user).to eq(recipient)
        expect(result.data.actor).to eq(actor)
        expect(result.data.notifiable).to eq(task)
        expect(result.data.event_type).to eq('task_assigned')
        expect(result.message).to eq('Notification created successfully')
      end

      it 'stores metadata correctly' do
        result = described_class.call(**valid_params)

        expect(result.data.metadata).to include(
          'task_title' => task.title,
          'project_id' => project.id
        )
      end

      it 'creates unread notification by default' do
        result = described_class.call(**valid_params)

        expect(result.data.unread?).to be true
        expect(result.data.read_at).to be_nil
      end
    end

    context 'when recipient is the same as actor' do
      it 'does not create notification' do
        params = valid_params.merge(recipient: actor)

        expect {
          described_class.call(**params)
        }.not_to change(Notification, :count)
      end

      it 'returns success with nil data' do
        params = valid_params.merge(recipient: actor)
        result = described_class.call(**params)

        expect(result.success?).to be true
        expect(result.data).to be_nil
        expect(result.message).to eq('No notification needed')
      end
    end

    context 'with different event types' do
      it 'creates mention notification' do
        comment = create(:comment, task: task, user: actor)
        result = described_class.call(
          recipient: recipient,
          actor: actor,
          notifiable: comment,
          event_type: :mention,
          metadata: { task_title: task.title, comment_excerpt: comment.content[0..50] }
        )

        expect(result.success?).to be true
        expect(result.data.event_type).to eq('mention')
      end

      it 'creates comment_added notification' do
        result = described_class.call(
          recipient: recipient,
          actor: actor,
          notifiable: task,
          event_type: :comment_added,
          metadata: { task_title: task.title }
        )

        expect(result.success?).to be true
        expect(result.data.event_type).to eq('comment_added')
      end

      it 'creates deadline_soon notification' do
        system_actor = create(:user, name: 'System') # Different user
        result = described_class.call(
          recipient: recipient,
          actor: system_actor,
          notifiable: task,
          event_type: :deadline_soon,
          metadata: { task_title: task.title, due_date: task.due_date }
        )

        expect(result.success?).to be true
        expect(result.data.event_type).to eq('deadline_soon')
      end
    end

    context 'with invalid parameters' do
      it 'fails when recipient is missing' do
        params = valid_params.merge(recipient: nil)
        result = described_class.call(**params)

        expect(result.success?).to be false
        expect(result.message).to eq('Failed to create notification')
        expect(result.errors[:user]).to be_present
      end

      it 'fails when actor is missing' do
        params = valid_params.merge(actor: nil)
        result = described_class.call(**params)

        expect(result.success?).to be false
        expect(result.errors[:actor]).to be_present
      end

      it 'fails when notifiable is missing' do
        params = valid_params.merge(notifiable: nil)
        result = described_class.call(**params)

        expect(result.success?).to be false
        expect(result.errors[:notifiable]).to be_present
      end

      it 'fails with invalid event_type' do
        params = valid_params.merge(event_type: :invalid_event)

        expect {
          described_class.call(**params)
        }.to raise_error(ArgumentError)
      end
    end

    context 'notification counts' do
      it 'increments notification count' do
        expect {
          described_class.call(**valid_params)
        }.to change(Notification, :count).by(1)
      end

      it 'increments recipient notifications count' do
        expect {
          described_class.call(**valid_params)
        }.to change { recipient.notifications.count }.by(1)
      end

      it 'increments actor triggered notifications count' do
        expect {
          described_class.call(**valid_params)
        }.to change { actor.triggered_notifications.count }.by(1)
      end
    end
  end
end
