class TaskSerializer < ApplicationSerializer
  attributes :id, :title, :description, :status, :priority, :due_date, :completed_at, :created_at, :updated_at

  # Relacionamentos
  belongs_to :project, serializer: :project
  belongs_to :user, serializer: :user
  has_many :comments, serializer: :comment

  # Atributos computados
  attribute :overdue do |object|
    object.overdue?
  end

  attribute :days_until_due do |object|
    object.days_until_due
  end
end
