require 'rails_helper'

RSpec.describe Webhooks::Dispatcher, type: :service do
  describe '.call' do
    let(:user) { create(:user) }
    let(:actor) { create(:user) }
    let(:project) { create(:project, user: user) }
    let(:task) { create(:task, project: project, user: user) }
    let(:notification) do
      create(:notification,
        user: user,
        actor: actor,
        notifiable: task,
        event_type: :task_assigned,
        metadata: { task_title: task.title, project_id: project.id }
      )
    end

    let!(:active_subscription) do
      create(:webhook_subscription,
        user: user,
        url: 'https://example.com/webhook',
        events: [ 'task_assigned', 'mention' ],
        active: true
      )
    end

    context 'with active webhooks for the event' do
      before do
        stub_request(:post, active_subscription.url)
          .to_return(status: 200, body: '{"success":true}')
      end

      it 'dispatches webhook successfully' do
        result = described_class.call(notification: notification)

        expect(result.success?).to be true
        expect(result.data.length).to eq(1)
        expect(result.data.first[:success]).to be true
        expect(result.message).to eq('Dispatched to 1 webhook(s)')
      end

      it 'sends correct payload' do
        described_class.call(notification: notification)

        expect(WebMock).to have_requested(:post, active_subscription.url)
          .with { |req|
            body = JSON.parse(req.body)
            body['event'] == 'task_assigned' &&
            body['data']['notification']['message'].present? &&
            body['data']['user']['id'] == user.id &&
            body['data']['actor']['id'] == actor.id
          }
      end

      it 'includes HMAC signature header' do
        described_class.call(notification: notification)

        expect(WebMock).to have_requested(:post, active_subscription.url)
          .with(headers: { 'X-Webhook-Signature' => /\A[a-f0-9]{64}\z/ })
      end

      it 'includes event type header' do
        described_class.call(notification: notification)

        expect(WebMock).to have_requested(:post, active_subscription.url)
          .with(headers: { 'X-Webhook-Event' => 'task_assigned' })
      end

      it 'updates subscription success timestamp' do
        expect {
          described_class.call(notification: notification)
        }.to change { active_subscription.reload.last_success_at }.from(nil)
      end

      it 'resets failure count on success' do
        active_subscription.update(failure_count: 3)

        described_class.call(notification: notification)

        expect(active_subscription.reload.failure_count).to eq(0)
      end
    end

    context 'when webhook request fails' do
      before do
        stub_request(:post, active_subscription.url)
          .to_return(status: 500, body: 'Internal Server Error')
      end

      it 'still returns success (dispatched, even if failed)' do
        result = described_class.call(notification: notification)

        expect(result.success?).to be true
        expect(result.data.first[:success]).to be false
      end

      it 'increments failure count' do
        expect {
          described_class.call(notification: notification)
        }.to change { active_subscription.reload.failure_count }.by(1)
      end

      it 'updates last_failure_at timestamp' do
        expect {
          described_class.call(notification: notification)
        }.to change { active_subscription.reload.last_failure_at }.from(nil)
      end

      it 'disables webhook after max failures' do
        active_subscription.update(failure_count: 4) # One more will hit the limit

        described_class.call(notification: notification)

        expect(active_subscription.reload.active).to be false
      end
    end

    context 'when webhook request times out' do
      before do
        stub_request(:post, active_subscription.url).to_timeout
      end

      it 'handles timeout gracefully' do
        result = described_class.call(notification: notification)

        expect(result.success?).to be true
        expect(result.data.first[:success]).to be false
      end

      it 'increments failure count' do
        expect {
          described_class.call(notification: notification)
        }.to change { active_subscription.reload.failure_count }.by(1)
      end
    end

    context 'with no active webhooks' do
      before do
        active_subscription.update(active: false)
      end

      it 'returns success with empty data' do
        result = described_class.call(notification: notification)

        expect(result.success?).to be true
        expect(result.data).to be_empty
        expect(result.message).to eq('No active webhooks for this event')
      end

      it 'does not make any HTTP requests' do
        described_class.call(notification: notification)

        expect(WebMock).not_to have_requested(:post, active_subscription.url)
      end
    end

    context 'with webhook not subscribed to event' do
      let!(:different_subscription) do
        create(:webhook_subscription,
          user: user,
          url: 'https://other.com/webhook',
          events: [ 'mention' ], # Not subscribed to task_assigned
          active: true
        )
      end

      it 'only dispatches to relevant webhooks' do
        stub_request(:post, active_subscription.url).to_return(status: 200)

        result = described_class.call(notification: notification)

        expect(result.data.length).to eq(1)
        expect(WebMock).to have_requested(:post, active_subscription.url)
        expect(WebMock).not_to have_requested(:post, different_subscription.url)
      end
    end

    context 'with multiple active webhooks' do
      let!(:second_subscription) do
        create(:webhook_subscription,
          user: user,
          url: 'https://second.com/webhook',
          events: [ 'task_assigned' ],
          active: true
        )
      end

      before do
        stub_request(:post, active_subscription.url).to_return(status: 200)
        stub_request(:post, second_subscription.url).to_return(status: 200)
      end

      it 'dispatches to all relevant webhooks' do
        result = described_class.call(notification: notification)

        expect(result.data.length).to eq(2)
        expect(WebMock).to have_requested(:post, active_subscription.url)
        expect(WebMock).to have_requested(:post, second_subscription.url)
      end
    end
  end
end
