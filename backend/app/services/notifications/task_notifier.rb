# app/services/notifications/task_notifier.rb
class Notifications::TaskNotifier < BaseService
  def self.call(task:, actor:, changes: {})
    new(task: task, actor: actor, changes: changes).call
  end

  def initialize(task:, actor:, changes: {})
    @task = task
    @actor = actor
    @changes = changes
  end

  def call
    notifications_created = []

    # Notify about status change
    if status_changed?
      status_notification = create_status_change_notification
      notifications_created << status_notification if status_notification

      # If completed, also create task_completed notification
      if completed?
        completed_notification = create_task_completed_notification
        notifications_created << completed_notification if completed_notification
      end
    end

    # Enqueue webhook delivery for all created notifications
    notifications_created.each do |notification|
      WebhookDeliveryJob.perform_later(notification.id)
    end

    success(
      data: { notifications_count: notifications_created.size },
      message: "#{notifications_created.size} notification(s) created"
    )
  end

  private

  attr_reader :task, :actor, :changes

  def status_changed?
    changes.key?(:status) && changes[:status].is_a?(Array) && changes[:status].size == 2
  end

  def completed?
    task.status == 'completed'
  end

  def create_status_change_notification
    task_owner = task.user
    return nil unless task_owner && task_owner != actor

    old_status, new_status = changes[:status]

    result = Notifications::Creator.call(
      recipient: task_owner,
      actor: actor,
      event_type: :task_status_changed,
      notifiable: task,
      metadata: {
        task_title: task.title,
        project_name: task.project.name,
        old_status: old_status,
        new_status: new_status
      }
    )

    result.success? ? result.data : nil
  end

  def create_task_completed_notification
    task_owner = task.user
    return nil unless task_owner && task_owner != actor

    result = Notifications::Creator.call(
      recipient: task_owner,
      actor: actor,
      event_type: :task_completed,
      notifiable: task,
      metadata: {
        task_title: task.title,
        project_name: task.project.name,
        completed_at: task.completed_at&.iso8601
      }
    )

    result.success? ? result.data : nil
  end
end
