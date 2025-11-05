# app/services/webhooks/dispatcher.rb
class Webhooks::Dispatcher < BaseService
  def self.call(notification:)
    new(notification: notification).call
  end

  def initialize(notification:)
    @notification = notification
  end

  def call
    subscriptions = find_active_subscriptions

    return success(data: [], message: 'No active webhooks for this event') if subscriptions.empty?

    dispatch_to_subscriptions(subscriptions)
  end

  private

  attr_reader :notification

  def find_active_subscriptions
    notification.user
      .webhook_subscriptions
      .active
      .listening_to(notification.event_type)
  end

  def dispatch_to_subscriptions(subscriptions)
    results = []

    subscriptions.each do |subscription|
      result = send_webhook(subscription)
      results << { subscription_id: subscription.id, success: result }
    end

    success(
      data: results,
      message: "Dispatched to #{results.count} webhook(s)"
    )
  end

  def send_webhook(subscription)
    payload = build_payload
    signature = subscription.generate_signature(payload)

    response = HTTP.timeout(10).headers(
      'Content-Type' => 'application/json',
      'X-Webhook-Signature' => signature,
      'X-Webhook-Event' => notification.event_type,
      'User-Agent' => 'Rails-Webhooks/1.0'
    ).post(subscription.url, body: payload)

    if response.status.success?
      subscription.record_success!
      true
    else
      subscription.record_failure!
      false
    end
  rescue StandardError => e
    Rails.logger.error("Webhook dispatch failed: #{e.message}")
    subscription.record_failure!
    false
  end

  def build_payload
    {
      id: notification.id,
      event: notification.event_type,
      created_at: notification.created_at.iso8601,
      data: {
        notification: {
          id: notification.id,
          message: notification.message,
          url: notification.url,
          read: notification.read?,
          metadata: notification.metadata
        },
        user: {
          id: notification.user.id,
          name: notification.user.name,
          email: notification.user.email
        },
        actor: {
          id: notification.actor.id,
          name: notification.actor.name
        },
        notifiable: {
          type: notification.notifiable_type,
          id: notification.notifiable_id
        }
      }
    }.to_json
  end
end
