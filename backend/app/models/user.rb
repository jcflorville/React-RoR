class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :nullify
  has_many :comments, dependent: :destroy

  # Notifications
  has_many :notifications, dependent: :destroy
  has_many :triggered_notifications, class_name: 'Notification', foreign_key: 'actor_id', dependent: :destroy

  # Webhooks
  has_many :webhook_subscriptions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  before_save :downcase_email

  # Generate new refresh token
  def generate_refresh_token!
    self.refresh_jti = SecureRandom.uuid
    self.refresh_token_expires_at = 30.days.from_now
    save!
  end

  # Check if refresh token is valid
  def refresh_token_valid?
    refresh_jti.present? && refresh_token_expires_at.present? && refresh_token_expires_at > Time.current
  end

  # Revoke refresh token
  def revoke_refresh_token!
    update!(refresh_jti: nil, refresh_token_expires_at: nil)
  end

  def full_name
    name
  end

  private

  def downcase_email
    self.email = email.downcase.strip
  end
end
