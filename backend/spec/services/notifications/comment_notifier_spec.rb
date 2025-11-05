# spec/services/notifications/comment_notifier_spec.rb
require 'rails_helper'

RSpec.describe Notifications::CommentNotifier, type: :service do
  describe '.call' do
    let(:task_owner) { create(:user) }
    let(:actor) { create(:user) }
    let(:mentioned_user) { create(:user) }
    let(:another_mentioned) { create(:user) }
    let(:project) { create(:project, user: task_owner) }
    let(:task) { create(:task, project: project, user: task_owner) }

    context 'with mentions and assignee notification' do
      let(:comment) do
        create(:comment,
               user: actor,
               task: task,
               content: "Hey @#{mentioned_user.email} and @#{another_mentioned.email}, please check this out!")
      end

      before do
        mentioned_user
        another_mentioned
      end

      it 'creates notifications for mentioned users and task owner' do
        expect {
          described_class.call(comment: comment, actor: actor)
        }.to change(Notification, :count).by(3) # 2 mentions + 1 comment_added

        mention_notifications = Notification.where(event_type: 'mention')
        expect(mention_notifications.count).to eq(2)
        expect(mention_notifications.pluck(:user_id)).to contain_exactly(
          mentioned_user.id,
          another_mentioned.id
        )

        comment_notification = Notification.find_by(event_type: 'comment_added')
        expect(comment_notification.user).to eq(task_owner)
      end

      it 'enqueues webhook delivery jobs for all notifications' do
        expect {
          described_class.call(comment: comment, actor: actor)
        }.to have_enqueued_job(WebhookDeliveryJob).exactly(3).times
      end

      it 'returns success with notification count' do
        result = described_class.call(comment: comment, actor: actor)

        expect(result.success?).to be true
        expect(result.data[:notifications_count]).to eq(3)
        expect(result.message).to eq('3 notification(s) created')
      end

      it 'includes correct metadata in notifications' do
        described_class.call(comment: comment, actor: actor)

        notification = Notification.first
        expect(notification.metadata['task_title']).to eq(task.title)
        expect(notification.metadata['project_name']).to eq(project.name)
        expect(notification.metadata['comment_content']).to be_present
      end
    end

    context 'with only mentions' do
      let(:comment) do
        create(:comment,
               user: task_owner, # Task owner commenting, no notification to self
               task: task,
               content: "Hey @#{mentioned_user.email}!")
      end

      before { mentioned_user }

      it 'creates only mention notifications' do
        expect {
          described_class.call(comment: comment, actor: task_owner)
        }.to change(Notification, :count).by(1) # Only mention, no comment_added (owner commenting)

        notification = Notification.last
        expect(notification.event_type).to eq('mention')
        expect(notification.user).to eq(mentioned_user)
      end
    end

    context 'with only task owner notification' do
      let(:comment) do
        create(:comment,
               user: actor,
               task: task,
               content: 'Regular comment without mentions')
      end

      it 'creates only comment_added notification for task owner' do
        expect {
          described_class.call(comment: comment, actor: actor)
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.event_type).to eq('comment_added')
        expect(notification.user).to eq(task_owner)
      end
    end

    context 'when actor is the task owner' do
      let(:comment) do
        create(:comment,
               user: task_owner,
               task: task,
               content: 'Comment without mentions')
      end

      it 'does not create comment_added notification' do
        expect {
          described_class.call(comment: comment, actor: task_owner)
        }.not_to change(Notification, :count)
      end

      it 'returns success with zero notifications' do
        result = described_class.call(comment: comment, actor: task_owner)

        expect(result.success?).to be true
        expect(result.data[:notifications_count]).to eq(0)
      end
    end

    context 'when mentioning yourself' do
      let(:comment) do
        create(:comment,
               user: actor,
               task: task,
               content: "Testing @#{actor.email} self-mention")
      end

      it 'does not create mention notification for actor' do
        described_class.call(comment: comment, actor: actor)

        mention_notifications = Notification.where(event_type: 'mention')
        expect(mention_notifications.count).to eq(0)
      end
    end

    context 'when mentioning non-existent users' do
      let(:comment) do
        create(:comment,
               user: actor,
               task: task,
               content: '@nonexistent@example.com please check')
      end

      it 'only creates comment_added notification' do
        expect {
          described_class.call(comment: comment, actor: actor)
        }.to change(Notification, :count).by(1)

        notification = Notification.last
        expect(notification.event_type).to eq('comment_added')
      end
    end

    context 'with no mentions and actor is task owner' do
      let(:comment) do
        create(:comment,
               user: task_owner,
               task: task,
               content: 'Regular comment')
      end

      it 'creates no notifications' do
        expect {
          described_class.call(comment: comment, actor: task_owner)
        }.not_to change(Notification, :count)
      end

      it 'returns success with zero notifications' do
        result = described_class.call(comment: comment, actor: task_owner)

        expect(result.success?).to be true
        expect(result.data[:notifications_count]).to eq(0)
      end
    end
  end
end
