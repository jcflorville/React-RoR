class Category < ApplicationRecord
  has_and_belongs_to_many :projects

  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 50 }
  validates :color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, message: 'deve ser um código de cor hexadecimal válido' }
  validates :description, length: { maximum: 500 }

  scope :ordered, -> { order(:name) }

  before_validation :set_default_color, on: :create

  private

  def set_default_color
    self.color ||= '#6B7280' # gray-500 como padrão
  end
end
