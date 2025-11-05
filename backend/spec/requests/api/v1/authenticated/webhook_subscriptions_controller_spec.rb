require 'rails_helper'

RSpec.describe Api::V1::Authenticated::WebhookSubscriptionsController, type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let!(:active_subscription) do
    create(:webhook_subscription,
      user: user,
      name: 'Slack Webhook',
      url: 'https://hooks.slack.com/services/xxx',
      events: [ 'mention', 'task_assigned' ],
      active: true
    )
  end

  let!(:inactive_subscription) do
    create(:webhook_subscription,
      user: user,
      name: 'Discord Webhook',
      active: false
    )
  end

  let!(:other_user_subscription) do
    create(:webhook_subscription, user: other_user)
  end

  describe 'GET /api/v1/webhook_subscriptions' do
    context 'when authenticated' do
      before { get '/api/v1/webhook_subscriptions', headers: auth_headers(user) }

      it 'returns success' do
        expect(response).to have_http_status(:success)
        expect_json_success
      end

      it 'returns only current user subscriptions' do
        expect(json_response['data'].length).to eq(2)
      end

      it 'includes subscription data' do
        subscription_data = json_response['data'].first

        expect(subscription_data).to include(
          'id',
          'name',
          'url',
          'events',
          'active',
          'status',
          'health',
          'created_at'
        )
      end

      it 'does not include secret by default' do
        subscription_data = json_response['data'].first
        expect(subscription_data).not_to have_key('secret')
      end
    end

    context 'with active filter' do
      before { get '/api/v1/webhook_subscriptions?active=true', headers: auth_headers(user) }

      it 'returns only active subscriptions' do
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['active']).to be true
      end
    end

    context 'with inactive filter' do
      before { get '/api/v1/webhook_subscriptions?active=false', headers: auth_headers(user) }

      it 'returns only inactive subscriptions' do
        expect(json_response['data'].length).to eq(1)
        expect(json_response['data'].first['active']).to be false
      end
    end
  end

  describe 'GET /api/v1/webhook_subscriptions/:id' do
    context 'with valid subscription' do
      before { get "/api/v1/webhook_subscriptions/#{active_subscription.id}", headers: auth_headers(user) }

      it 'returns success' do
        expect(response).to have_http_status(:success)
        expect_json_success
      end

      it 'returns subscription data' do
        expect(json_response['data']['id']).to eq(active_subscription.id)
        expect(json_response['data']['name']).to eq('Slack Webhook')
      end
    end

    context 'with other user subscription' do
      before { get "/api/v1/webhook_subscriptions/#{other_user_subscription.id}", headers: auth_headers(user) }

      it 'returns not found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/webhook_subscriptions' do
    let(:valid_params) do
      {
        webhook_subscription: {
          name: 'New Webhook',
          url: 'https://example.com/webhook',
          events: [ 'mention', 'task_completed' ]
        }
      }
    end

    context 'with valid params' do
      it 'creates new subscription' do
        expect {
          post '/api/v1/webhook_subscriptions', params: valid_params.to_json, headers: auth_headers(user)
        }.to change(WebhookSubscription, :count).by(1)
      end

      it 'returns success' do
        post '/api/v1/webhook_subscriptions', params: valid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:created)
        expect_json_success
      end

      it 'returns created subscription with secret' do
        post '/api/v1/webhook_subscriptions', params: valid_params.to_json, headers: auth_headers(user)

        expect(json_response['data']['name']).to eq('New Webhook')
        expect(json_response['data']['url']).to eq('https://example.com/webhook')
        expect(json_response['data']['events']).to eq([ 'mention', 'task_completed' ])
        expect(json_response['data']['secret']).to be_present # Secret shown on creation
      end

      it 'auto-generates secret' do
        post '/api/v1/webhook_subscriptions', params: valid_params.to_json, headers: auth_headers(user)

        subscription = WebhookSubscription.last
        expect(subscription.secret).to be_present
        expect(subscription.secret.length).to eq(64) # 32 bytes hex
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          webhook_subscription: {
            name: '',
            url: 'invalid-url',
            events: []
          }
        }
      end

      it 'does not create subscription' do
        expect {
          post '/api/v1/webhook_subscriptions', params: invalid_params.to_json, headers: auth_headers(user)
        }.not_to change(WebhookSubscription, :count)
      end

      it 'returns error' do
        post '/api/v1/webhook_subscriptions', params: invalid_params.to_json, headers: auth_headers(user)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_response['success']).to be false
      end

      it 'returns validation errors' do
        post '/api/v1/webhook_subscriptions', params: invalid_params.to_json, headers: auth_headers(user)

        expect(json_response['errors']).to be_present
        expect(json_response['errors']).to have_key('name')
        expect(json_response['errors']).to have_key('url')
      end
    end
  end

  describe 'PATCH /api/v1/webhook_subscriptions/:id' do
    let(:update_params) do
      {
        webhook_subscription: {
          name: 'Updated Webhook',
          events: [ 'mention' ]
        }
      }
    end

    context 'with valid params' do
      before do
        patch "/api/v1/webhook_subscriptions/#{active_subscription.id}",
              params: update_params.to_json,
              headers: auth_headers(user)
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
        expect_json_success
      end

      it 'updates subscription' do
        expect(active_subscription.reload.name).to eq('Updated Webhook')
        expect(active_subscription.events).to eq([ 'mention' ])
      end

      it 'does not expose secret after update' do
        expect(json_response['data']).not_to have_key('secret')
      end
    end

    context 'with other user subscription' do
      it 'returns not found' do
        patch "/api/v1/webhook_subscriptions/#{other_user_subscription.id}",
              params: update_params.to_json,
              headers: auth_headers(user)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/webhook_subscriptions/:id' do
    it 'deletes the subscription' do
      expect {
        delete "/api/v1/webhook_subscriptions/#{active_subscription.id}", headers: auth_headers(user)
      }.to change(WebhookSubscription, :count).by(-1)
    end

    it 'returns success' do
      delete "/api/v1/webhook_subscriptions/#{active_subscription.id}", headers: auth_headers(user)

      expect(response).to have_http_status(:success)
      expect_json_success
    end
  end

  describe 'POST /api/v1/webhook_subscriptions/:id/enable' do
    before do
      post "/api/v1/webhook_subscriptions/#{inactive_subscription.id}/enable",
           headers: auth_headers(user)
    end

    it 'returns success' do
      expect(response).to have_http_status(:success)
      expect_json_success
    end

    it 'enables the subscription' do
      expect(inactive_subscription.reload.active).to be true
      expect(json_response['data']['active']).to be true
      expect(json_response['data']['status']).to eq('active')
    end

    it 'resets failure count' do
      expect(inactive_subscription.reload.failure_count).to eq(0)
    end
  end

  describe 'POST /api/v1/webhook_subscriptions/:id/disable' do
    before do
      post "/api/v1/webhook_subscriptions/#{active_subscription.id}/disable",
           headers: auth_headers(user)
    end

    it 'returns success' do
      expect(response).to have_http_status(:success)
      expect_json_success
    end

    it 'disables the subscription' do
      expect(active_subscription.reload.active).to be false
      expect(json_response['data']['active']).to be false
      expect(json_response['data']['status']).to eq('inactive')
    end
  end
end
