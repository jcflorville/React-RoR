class Task < ApplicationRecord
  include PgSearch::Model

  belongs_to :project
  belongs_to :user
  has_many :comments, dependent: :destroy

  # Configuração de busca
  pg_search_scope :search_by_content,
                  against: [ :title, :description ],
                  using: {
                    tsearch: { prefix: true },
                    trigram: { threshold: 0.3 }
                  }

  enum :status, { todo: 0, in_progress: 1, completed: 2, blocked: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true, length: { minimum: 2, maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :status, presence: true
  validates :priority, presence: true

  scope :ordered, -> { order(:created_at) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }
  scope :overdue, -> { where('due_date < ? AND status != ?', Time.current, statuses[:completed]) }

  before_validation :set_defaults, on: :create
  before_update :set_completed_at

  def overdue?
    due_date.present? && due_date < Time.current && !completed?
  end

  def days_until_due
    return nil unless due_date
    (due_date.to_date - Date.current).to_i
  end

  private

  def set_defaults
    self.status ||= :todo
    self.priority ||= :medium
  end

  def set_completed_at
    if status_changed? && completed?
      self.completed_at = Time.current
    elsif status_changed? && !completed?
      self.completed_at = nil
    end
  end
end
