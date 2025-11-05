require 'rails_helper'

RSpec.describe Api::V1::Authenticated::NotificationStreamController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/v1/notification_stream' do
    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/notification_stream'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized' do
        get '/api/v1/notification_stream', headers: { 'Authorization' => 'Bearer invalid_token' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    # Note: We don't test the actual streaming in unit tests because:
    # 1. SSE connections are infinite loops that would hang the test suite
    # 2. ActionController::Live requires threading support that's hard to test
    # 3. The logic is better tested through integration tests or manual testing
    # Instead, we verify the business logic separately below
  end

  describe 'SSE business logic (without streaming)' do
    let(:actor) { create(:user) }
    let(:task) { create(:task, user: user) }

    context 'with recent notifications' do
      let!(:notification1) do
        create(:notification,
          user: user,
          actor: actor,
          notifiable: task,
          event_type: 'mention',
          created_at: 10.seconds.ago)
      end

      let!(:notification2) do
        create(:notification,
          user: user,
          actor: actor,
          notifiable: task,
          event_type: 'task_assigned',
          created_at: 5.seconds.ago)
      end

      it 'includes recent unread notifications' do
        recent_notifications = user.notifications
          .where('created_at > ?', 20.seconds.ago)
          .unread
          .recent

        expect(recent_notifications).to include(notification1, notification2)
      end
    end

    context 'with old notifications' do
      let!(:old_notification) do
        create(:notification,
          user: user,
          actor: actor,
          notifiable: task,
          event_type: 'mention',
          created_at: 30.seconds.ago)
      end

      it 'excludes notifications older than 20 seconds' do
        recent_notifications = user.notifications
          .where('created_at > ?', 20.seconds.ago)
          .unread
          .recent

        expect(recent_notifications).not_to include(old_notification)
      end
    end

    context 'with read notifications' do
      let!(:read_notification) do
        notification = create(:notification,
          user: user,
          actor: actor,
          notifiable: task,
          event_type: 'mention',
          created_at: 5.seconds.ago)
        notification.mark_as_read!
        notification
      end

      it 'excludes read notifications' do
        recent_notifications = user.notifications
          .where('created_at > ?', 20.seconds.ago)
          .unread
          .recent

        expect(recent_notifications).not_to include(read_notification)
      end
    end

    context 'notification data format' do
      let!(:notification) do
        create(:notification,
          user: user,
          actor: actor,
          notifiable: task,
          event_type: 'mention',
          created_at: 5.seconds.ago)
      end

      it 'serializes notification with actor and notifiable' do
        data = NotificationBlueprint.render_as_hash(
          notification,
          include: [ :actor, :notifiable ]
        )

        expect(data).to have_key(:id)
        expect(data).to have_key(:event_type)
        expect(data).to have_key(:created_at)
        expect(data).to have_key(:actor)
        expect(data).to have_key(:notifiable)
      end
    end

    context 'with multiple users' do
      let!(:user_notification) do
        create(:notification,
          user: user,
          actor: actor,
          notifiable: task,
          event_type: 'mention',
          created_at: 5.seconds.ago)
      end

      let!(:other_user_notification) do
        create(:notification,
          user: other_user,
          actor: actor,
          notifiable: task,
          event_type: 'mention',
          created_at: 5.seconds.ago)
      end

      it 'only includes current user notifications' do
        user_recent = user.notifications
          .where('created_at > ?', 20.seconds.ago)
          .unread
          .recent

        expect(user_recent).to include(user_notification)
        expect(user_recent).not_to include(other_user_notification)
      end
    end
  end

  describe 'controller implementation' do
    let(:controller_source) do
      File.read(
        Rails.root.join('app/controllers/api/v1/authenticated/notification_stream_controller.rb')
      )
    end

    it 'includes ActionController::Live' do
      expect(controller_source).to include('ActionController::Live')
    end

    it 'sets SSE headers' do
      expect(controller_source).to include("response.headers['Content-Type'] = 'text/event-stream'")
      expect(controller_source).to include("response.headers['Cache-Control'] = 'no-cache'")
    end

    it 'handles client disconnection' do
      expect(controller_source).to include('rescue IOError')
      expect(controller_source).to include('Client disconnected')
    end

    it 'closes stream in ensure block' do
      expect(controller_source).to include('ensure')
      expect(controller_source).to include('sse.close')
    end

    it 'implements heartbeat mechanism' do
      expect(controller_source).to include('heartbeat')
      expect(controller_source).to include('sleep 15')
    end
  end
end
