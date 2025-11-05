class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      # Recipient (user who receives the notification)
      t.references :user, null: false, foreign_key: true

      # Actor (user who triggered the notification)
      t.references :actor, null: false, foreign_key: { to_table: :users }

      # Polymorphic association to the resource (Task, Comment, Project, etc.)
      t.references :notifiable, polymorphic: true, null: false

      # Event type enum (will be defined in model)
      # Examples: mention, task_assigned, comment_added, task_completed, deadline_soon
      t.integer :event_type, null: false, default: 0

      # Additional data (JSON) - flexible for storing event-specific information
      # Examples: { "task_title": "...", "comment_excerpt": "...", "mentioned_by": "..." }
      t.jsonb :metadata, default: {}, null: false

      # Read/unread tracking
      t.datetime :read_at

      t.timestamps
    end

    # Indexes for performance
    add_index :notifications, [ :user_id, :read_at ], name: 'index_notifications_on_user_and_read'
    add_index :notifications, [ :user_id, :event_type ], name: 'index_notifications_on_user_and_event_type'
    add_index :notifications, :created_at
  end
end
