require 'rails_helper'

RSpec.describe WebhookSubscriptionBlueprint, type: :blueprint do
  let(:user) { create(:user) }
  let(:webhook_subscription) do
    create(:webhook_subscription,
      user: user,
      name: 'Slack Integration',
      url: 'https://hooks.slack.com/services/xxx',
      events: [ 'mention', 'task_assigned' ],
      active: true
    )
  end

  describe 'serialization' do
    subject(:serialized) { JSON.parse(WebhookSubscriptionBlueprint.render(webhook_subscription)) }

    it 'includes identifier' do
      expect(serialized['id']).to eq(webhook_subscription.id)
    end

    it 'includes basic fields' do
      expect(serialized).to include(
        'name' => 'Slack Integration',
        'url' => 'https://hooks.slack.com/services/xxx',
        'events' => [ 'mention', 'task_assigned' ],
        'active' => true
      )
    end

    it 'includes timestamps' do
      expect(serialized).to have_key('created_at')
      expect(serialized).to have_key('updated_at')
    end

    it 'includes failure tracking fields' do
      expect(serialized).to have_key('failure_count')
      expect(serialized).to have_key('last_failure_at')
      expect(serialized).to have_key('last_success_at')
    end

    it 'includes computed status field' do
      expect(serialized['status']).to eq('active')
    end

    it 'includes computed health field' do
      expect(serialized['health']).to eq('healthy')
    end

    it 'does not include secret by default' do
      expect(serialized).not_to have_key('secret')
    end

    context 'with show_secret option' do
      subject(:serialized) do
        JSON.parse(WebhookSubscriptionBlueprint.render(webhook_subscription, show_secret: true))
      end

      it 'includes secret when explicitly requested' do
        expect(serialized['secret']).to be_present
        expect(serialized['secret']).to eq(webhook_subscription.secret)
      end
    end

    context 'when webhook is inactive' do
      before { webhook_subscription.update(active: false) }

      it 'reflects inactive status' do
        result = JSON.parse(WebhookSubscriptionBlueprint.render(webhook_subscription))
        expect(result['status']).to eq('inactive')
        expect(result['active']).to eq(false)
      end
    end

    context 'health status' do
      it 'shows healthy when no failures' do
        webhook_subscription.update(failure_count: 0)
        result = JSON.parse(WebhookSubscriptionBlueprint.render(webhook_subscription))
        expect(result['health']).to eq('healthy')
      end

      it 'shows degraded when 1-2 failures' do
        webhook_subscription.update(failure_count: 2)
        result = JSON.parse(WebhookSubscriptionBlueprint.render(webhook_subscription))
        expect(result['health']).to eq('degraded')
      end

      it 'shows unhealthy when 3+ failures' do
        webhook_subscription.update(failure_count: 3)
        result = JSON.parse(WebhookSubscriptionBlueprint.render(webhook_subscription))
        expect(result['health']).to eq('unhealthy')
      end
    end
  end

  describe 'collection serialization' do
    let!(:webhooks) do
      [
        create(:webhook_subscription, user: user, name: 'Slack'),
        create(:webhook_subscription, user: user, name: 'Discord', active: false)
      ]
    end

    subject(:serialized) { JSON.parse(WebhookSubscriptionBlueprint.render(webhooks)) }

    it 'serializes multiple webhooks' do
      expect(serialized).to be_an(Array)
      expect(serialized.length).to eq(2)
    end

    it 'includes all webhook data' do
      expect(serialized.first).to have_key('id')
      expect(serialized.first).to have_key('name')
      expect(serialized.first).to have_key('url')
      expect(serialized.first).to have_key('events')
      expect(serialized.first).to have_key('status')
      expect(serialized.first).to have_key('health')
    end

    it 'does not include secret by default for any webhook' do
      expect(serialized.first).not_to have_key('secret')
      expect(serialized.last).not_to have_key('secret')
    end
  end
end
