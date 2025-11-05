class WebhookDeliveryJob < ApplicationJob
  queue_as :default

  # Retry with exponential backoff: 3s, 30s, 5min, 30min
  retry_on StandardError, wait: :exponentially_longer, attempts: 4

  # Discard if notification is deleted
  discard_on ActiveJob::DeserializationError

  def perform(notification_id)
    notification = Notification.find(notification_id)

    # Dispatch to all active webhooks listening to this event
    result = Webhooks::Dispatcher.call(notification: notification)

    # Log if there were any issues (Dispatcher handles per-subscription failures internally)
    unless result.success?
      Rails.logger.warn("[WebhookDeliveryJob] #{result.message}")
    end
  end
end
