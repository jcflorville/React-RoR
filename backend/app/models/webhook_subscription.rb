class WebhookSubscription < ApplicationRecord
  # Associations
  belongs_to :user

  # Constants
  MAX_FAILURES = 5 # Auto-disable after 5 consecutive failures

  # Validations
  validates :user, presence: true
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid HTTP(S) URL' }
  validates :secret, presence: true
  validate :events_must_be_present_and_valid

  # Callbacks
  before_validation :generate_secret, on: :create
  before_validation :normalize_url

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :for_user, ->(user) { where(user: user) }
  scope :listening_to, ->(event) { where('? = ANY(events)', event.to_s) }

  # Class methods
  def self.available_events
    Notification.event_types.keys
  end

  # Instance methods
  def listening_to?(event)
    events.include?(event.to_s)
  end

  def record_success!
    update(
      last_success_at: Time.current,
      failure_count: 0
    )
  end

  def record_failure!
    increment!(:failure_count)
    update(last_failure_at: Time.current)

    # Auto-disable after too many failures
    disable! if failure_count >= MAX_FAILURES
  end

  def disable!
    update(active: false)
  end

  def enable!
    update(active: true, failure_count: 0)
  end

  def generate_signature(payload)
    OpenSSL::HMAC.hexdigest('SHA256', secret, payload)
  end

  private

  def generate_secret
    self.secret ||= SecureRandom.hex(32)
  end

  def normalize_url
    self.url = url&.strip
  end

  def events_must_be_present_and_valid
    if events.blank? || events.empty?
      errors.add(:events, 'must include at least one event')
      return
    end

    invalid_events = events - self.class.available_events
    if invalid_events.any?
      errors.add(:events, "contains invalid events: #{invalid_events.join(', ')}")
    end
  end
end
