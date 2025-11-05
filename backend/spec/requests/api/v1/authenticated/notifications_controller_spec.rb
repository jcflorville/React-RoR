require 'rails_helper'

RSpec.describe Api::V1::Authenticated::NotificationsController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:task) { create(:task, project: project, user: user) }

  let!(:notification1) do
    create(:notification,
      user: user,
      actor: other_user,
      notifiable: task,
      event_type: :task_assigned
    )
  end

  let!(:notification2) do
    create(:notification,
      user: user,
      actor: other_user,
      notifiable: task,
      event_type: :mention
    )
  end

  let!(:read_notification) do
    create(:notification, :read,
      user: user,
      actor: other_user,
      notifiable: task
    )
  end

  let!(:other_user_notification) do
    create(:notification,
      user: other_user,
      actor: user,
      notifiable: task
    )
  end

  describe 'GET /api/v1/notifications' do
    context 'when authenticated' do
      before { get '/api/v1/notifications', headers: auth_headers(user) }

      it 'returns success' do
        expect(response).to have_http_status(:success)
        expect_json_success
      end

      it 'returns only current user notifications' do
        expect(json_response['data'].length).to eq(3) # 2 unread + 1 read
      end

      it 'includes notification data' do
        notification_data = json_response['data'].first

        expect(notification_data).to include(
          'id',
          'event_type',
          'message',
          'url',
          'read',
          'unread',
          'created_at'
        )
      end

          it 'includes actor association' do
      get '/api/v1/notifications?include=actor', headers: auth_headers(user)

      notification_data = json_response['data'].first
      expect(notification_data['actor']).to be_present
      expect(notification_data['actor']['id']).to eq(other_user.id)
    end

      it 'returns notifications in descending order' do
        ids = json_response['data'].map { |n| n['id'] }
        expect(ids).to eq(ids.sort.reverse)
      end
    end

    context 'with unread filter' do
      before { get '/api/v1/notifications?unread=true', headers: auth_headers(user) }

      it 'returns only unread notifications' do
        expect(json_response['data'].length).to eq(2)
        json_response['data'].each do |notification|
          expect(notification['unread']).to be true
        end
      end
    end

    context 'with event_type filter' do
      before { get '/api/v1/notifications?event_type=mention', headers: auth_headers(user) }

      it 'returns only notifications of specified type' do
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['event_type']).to eq('mention')
      end
    end

    context 'when not authenticated' do
      before { get '/api/v1/notifications' }

      it 'returns unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/notifications/unread_count' do
    before { get '/api/v1/notifications/unread_count', headers: auth_headers(user) }

    it 'returns success' do
      expect(response).to have_http_status(:success)
      expect_json_success
    end

    it 'returns correct unread count' do
      expect(json_response['data']['count']).to eq(2)
    end
  end

  describe 'GET /api/v1/notifications/:id' do
    context 'with valid notification' do
      before { get "/api/v1/notifications/#{notification1.id}?include=actor,notifiable", headers: auth_headers(user) }

      it 'returns success' do
        expect(response).to have_http_status(:success)
        expect_json_success
      end

      it 'returns notification data' do
        expect(json_response['data']['id']).to eq(notification1.id)
        expect(json_response['data']['event_type']).to eq('task_assigned')
      end

      it 'includes actor' do
        expect(json_response['data']['actor']).to be_present
      end

      it 'includes notifiable' do
        expect(json_response['data']['notifiable']).to be_present
        expect(json_response['data']['notifiable']['id']).to eq(task.id)
      end
    end

    context 'with other user notification' do
      before { get "/api/v1/notifications/#{other_user_notification.id}", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/v1/notifications/:id/mark_as_read' do
    before { patch "/api/v1/notifications/#{notification1.id}/mark_as_read", headers: auth_headers(user) }

    it 'returns success' do
      expect(response).to have_http_status(:success)
      expect_json_success
    end

    it 'marks notification as read' do
      expect(notification1.reload.read?).to be true
      expect(json_response['data']['read']).to be true
    end

    it 'returns updated notification' do
      expect(json_response['data']['read_at']).to be_present
    end
  end

  describe 'PATCH /api/v1/notifications/:id/mark_as_unread' do
    before { patch "/api/v1/notifications/#{read_notification.id}/mark_as_unread", headers: auth_headers(user) }

    it 'returns success' do
      expect(response).to have_http_status(:success)
      expect_json_success
    end

    it 'marks notification as unread' do
      expect(read_notification.reload.unread?).to be true
      expect(json_response['data']['unread']).to be true
    end
  end

  describe 'POST /api/v1/notifications/mark_all_as_read' do
    it 'marks all unread notifications as read' do
      expect {
        post '/api/v1/notifications/mark_all_as_read', headers: auth_headers(user)
      }.to change { user.notifications.unread.count }.from(2).to(0)
    end

    it 'returns success' do
      post '/api/v1/notifications/mark_all_as_read', headers: auth_headers(user)

      expect(response).to have_http_status(:success)
      expect_json_success
      expect(json_response['message']).to eq('All notifications marked as read')
    end
  end

  describe 'DELETE /api/v1/notifications/:id' do
    it 'deletes the notification' do
      expect {
        delete "/api/v1/notifications/#{notification1.id}", headers: auth_headers(user)
      }.to change(Notification, :count).by(-1)
    end

    it 'returns success' do
      delete "/api/v1/notifications/#{notification1.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:success)
      expect_json_success
    end

    context 'with other user notification' do
      it 'does not delete notification' do
        expect {
          delete "/api/v1/notifications/#{other_user_notification.id}", headers: auth_headers(user)
        }.not_to change(Notification, :count)
      end

      it 'returns not found' do
        delete "/api/v1/notifications/#{other_user_notification.id}", headers: auth_headers(user)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
