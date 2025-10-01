class ProjectSerializer < ApplicationSerializer
  attributes :id, :name, :description, :status, :priority, :start_date, :end_date, :created_at, :updated_at

  # Relacionamentos (comentados temporariamente para debug)
  # belongs_to :user, serializer: :user
  # has_many :tasks, serializer: :task
  # has_many :categories, serializer: :category

  # Atributos computados
  attribute :progress_percentage do |object|
    object.progress_percentage
  end

  attribute :overdue do |object|
    object.overdue?
  end

  attribute :status_humanized do |object|
    object.status.humanize
  end

  attribute :priority_humanized do |object|
    object.priority.humanize
  end
end
