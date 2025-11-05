class NotificationBlueprint < ApplicationBlueprint
  identifier :id

  fields :event_type, :metadata, :read_at, :created_at, :updated_at

  # Computed fields
  field :read do |notification|
    notification.read?
  end

  field :unread do |notification|
    notification.unread?
  end

  field :message do |notification|
    notification.message
  end

  field :url do |notification|
    notification.url
  end

  # Always include notifiable_type and notifiable_id for frontend linking
  field :notifiable_type
  field :notifiable_id

  # Actor (who triggered the notification) - always included
  association :actor, blueprint: UserBlueprint

  # Notifiable resource (polymorphic - Task, Comment, Project) - conditional
  # Use dynamic blueprint based on notifiable type
  field :notifiable, if: include_condition(:notifiable) do |notification, options|
    case notification.notifiable_type
    when 'Task'
      TaskBlueprint.render_as_hash(notification.notifiable, options)
    when 'Comment'
      CommentBlueprint.render_as_hash(notification.notifiable, options)
    when 'Project'
      ProjectBlueprint.render_as_hash(notification.notifiable, options)
    else
      { id: notification.notifiable_id, type: notification.notifiable_type }
    end
  end
end
