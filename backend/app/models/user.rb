class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :projects, dependent: :destroy
  has_many :tasks, dependent: :nullify
  has_many :comments, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  before_save :downcase_email

  def full_name
    name
  end

  private

  def downcase_email
    self.email = email.downcase.strip
  end
end
