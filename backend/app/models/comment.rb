class Comment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  scope :ordered, -> { order(:created_at) }
  scope :recent, -> { order(created_at: :desc) }

  before_update :set_edited_at

  def edited?
    edited_at.present?
  end

  def time_since_created
    time_ago_in_words(created_at)
  end

  private

  def set_edited_at
    if content_changed? && persisted?
      self.edited_at = Time.current
    end
  end
end
