# app/services/notifications/comment_notifier.rb
class Notifications::CommentNotifier < BaseService
  def self.call(comment:, actor:)
    new(comment: comment, actor: actor).call
  end

  def initialize(comment:, actor:)
    @comment = comment
    @actor = actor
    @task = comment.task
  end

  def call
    notifications_created = []

    # Create mention notifications for @mentioned users
    notifications_created += create_mention_notifications

    # Notify task assignee about new comment (if not the commenter)
    assignee_notification = create_comment_added_notification
    notifications_created << assignee_notification if assignee_notification

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

  attr_reader :comment, :actor, :task

  def create_mention_notifications
    mentioned_emails = extract_mentions
    return [] if mentioned_emails.empty?

    mentioned_users = User.where(email: mentioned_emails)
    notifications = []

    mentioned_users.each do |mentioned_user|
      next if mentioned_user == actor # Don't notify yourself

      result = Notifications::Creator.call(
        recipient: mentioned_user,
        actor: actor,
        event_type: :mention,
        notifiable: comment,
        metadata: build_metadata
      )

      notifications << result.data if result.success?
    end

    notifications
  end

  def create_comment_added_notification
    # Notify task owner about new comment (if not the commenter)
    task_owner = task.user
    return nil unless task_owner && task_owner != actor

    result = Notifications::Creator.call(
      recipient: task_owner,
      actor: actor,
      event_type: :comment_added,
      notifiable: comment,
      metadata: build_metadata
    )

    result.success? ? result.data : nil
  end

  def extract_mentions
    # Extract @mentions from comment content (e.g., @user@example.com or @email)
    # Match email-like patterns after @
    comment.content.scan(/@([\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+)/i).map(&:first).uniq
  end

  def build_metadata
    {
      comment_content: comment.content.truncate(100),
      task_title: task.title,
      project_name: task.project.name
    }
  end
end
