class Project < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :tasks, dependent: :destroy
  has_and_belongs_to_many :categories

  # Configuração de busca
  pg_search_scope :search_by_content,
                  against: [ :name, :description ],
                  using: {
                    tsearch: { prefix: true },
                    trigram: { threshold: 0.3 }
                  }

  enum :status, { draft: 0, active: 1, completed: 2, archived: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 2000 }
  validates :status, presence: true
  validates :priority, presence: true
  validate :end_date_after_start_date

  scope :ordered, -> { order(:name) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_priority, ->(priority) { where(priority: priority) }

  before_validation :set_defaults, on: :create

  def progress_percentage
    return 0 if tasks.empty?
    (tasks.completed.count.to_f / tasks.count * 100).round(2)
  end

  def overdue?
    end_date.present? && end_date < Date.current && !completed?
  end

  private

  def set_defaults
    self.status ||= :draft
    self.priority ||= :medium
    self.start_date ||= Date.current
  end

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, 'deve ser posterior à data de início') if end_date < start_date
  end
end
