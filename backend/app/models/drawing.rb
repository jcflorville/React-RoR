class Drawing < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 255 }
  validates :canvas_data, presence: true
  validates :lock_version, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
