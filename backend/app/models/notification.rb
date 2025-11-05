class Notification < ApplicationRecord
  # Associations
  belongs_to :user # Recipient
  belongs_to :actor, class_name: 'User' # Who triggered the notification
  belongs_to :notifiable, polymorphic: true # Task, Comment, Project, etc.

  # Enums for event types
  enum :event_type, {
    mention: 0,              # User mentioned in comment
    task_assigned: 1,        # Task assigned to user
    task_completed: 2,       # Task marked as completed
    comment_added: 3,        # Comment added to task
    deadline_soon: 4,        # Task deadline approaching (< 2 days)
    project_shared: 5,       # Project shared with user
    task_status_changed: 6   # Task status updated
  }

  # Validations
  validates :user, presence: true
  validates :actor, presence: true
  validates :notifiable, presence: true
  validates :event_type, presence: true
  validates :metadata, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :by_event_type, ->(event_type) { where(event_type: event_type) }

  # Instance methods
  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  def mark_as_unread!
    update(read_at: nil) if read?
  end

  # Return human-friendly message based on event type
  def message
    case event_type.to_sym
    when :mention
      "#{actor.name} mentioned you in a comment"
    when :task_assigned
      "#{actor.name} assigned you to \"#{metadata['task_title']}\""
    when :task_completed
      "#{actor.name} completed the task \"#{metadata['task_title']}\""
    when :comment_added
      "#{actor.name} commented on \"#{metadata['task_title']}\""
    when :deadline_soon
      "Task \"#{metadata['task_title']}\" is due soon"
    when :project_shared
      "#{actor.name} shared the project \"#{metadata['project_name']}\" with you"
    when :task_status_changed
      "#{actor.name} changed status of \"#{metadata['task_title']}\" to #{metadata['new_status']}"
    else
      'New notification'
    end
  end

  # Generate URL for notification (frontend routing)
  def url
    case notifiable_type
    when 'Task'
      "/projects/#{metadata['project_id']}/tasks/#{notifiable_id}"
    when 'Comment'
      "/projects/#{metadata['project_id']}/tasks/#{metadata['task_id']}"
    when 'Project'
      "/projects/#{notifiable_id}"
    else
      '/'
    end
  end
end
