# app/services/notifications/creator.rb
class Notifications::Creator < BaseService
  def self.call(recipient:, actor:, notifiable:, event_type:, metadata: {})
    new(
      recipient: recipient,
      actor: actor,
      notifiable: notifiable,
      event_type: event_type,
      metadata: metadata
    ).call
  end

  def initialize(recipient:, actor:, notifiable:, event_type:, metadata: {})
    @recipient = recipient
    @actor = actor
    @notifiable = notifiable
    @event_type = event_type
    @metadata = metadata
  end

  def call
    # Don't create notification if user is notifying themselves
    return success(data: nil, message: 'No notification needed') if recipient == actor

    create_notification
  end

  private

  attr_reader :recipient, :actor, :notifiable, :event_type, :metadata

  def create_notification
    notification = Notification.new(
      user: recipient,
      actor: actor,
      notifiable: notifiable,
      event_type: event_type,
      metadata: metadata
    )

    if notification.save
      # Trigger webhook dispatch asynchronously (will be created later)
      # WebhookDeliveryJob.perform_later(notification.id) if notification.persisted?

      success(data: notification, message: 'Notification created successfully')
    else
      failure(errors: format_errors(notification), message: 'Failed to create notification')
    end
  end
end
