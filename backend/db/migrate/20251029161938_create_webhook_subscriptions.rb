class CreateWebhookSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :webhook_subscriptions do |t|
      # Owner of the webhook
      t.references :user, null: false, foreign_key: true

      # Webhook endpoint URL
      t.string :url, null: false

      # Name/description for the webhook (e.g., "Slack notifications", "Discord bot")
      t.string :name, null: false

      # Events to listen to (array of strings)
      # Examples: ["mention", "task_assigned", "comment_added"]
      # Store as array in PostgreSQL
      t.string :events, array: true, default: [], null: false

      # Secret for HMAC signature verification
      # Generated automatically, used to sign webhook payloads
      t.string :secret, null: false

      # Active/inactive toggle
      t.boolean :active, default: true, null: false

      # Failure tracking for automatic disabling
      t.integer :failure_count, default: 0, null: false
      t.datetime :last_failure_at

      # Success tracking
      t.datetime :last_success_at

      t.timestamps
    end

    # Indexes
    add_index :webhook_subscriptions, [ :user_id, :active ], name: 'index_webhook_subscriptions_on_user_and_active'
    add_index :webhook_subscriptions, :events, using: 'gin'
  end
end
