class WebhookSubscriptionBlueprint < ApplicationBlueprint
  identifier :id

  fields :name, :url, :events, :active, :created_at, :updated_at

  # Computed fields
  field :failure_count
  field :last_failure_at
  field :last_success_at

  field :status do |subscription|
    subscription.active? ? 'active' : 'inactive'
  end

  field :health do |subscription|
    if subscription.failure_count >= 3
      'unhealthy'
    elsif subscription.failure_count > 0
      'degraded'
    else
      'healthy'
    end
  end

  # Don't expose secret by default for security
  # Can be explicitly included if needed (e.g., when creating)
  field :secret, if: ->(_, _, options) { options[:show_secret] == true }
end
