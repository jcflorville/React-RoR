class CategorySerializer < ApplicationSerializer
  attributes :id, :name, :color, :description, :created_at, :updated_at

  # Relacionamentos
  has_many :projects, serializer: :project
end
