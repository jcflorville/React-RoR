class CommentSerializer < ApplicationSerializer
  attributes :id, :content, :edited_at, :created_at, :updated_at

  # Relacionamentos
  belongs_to :task, serializer: :task
  belongs_to :user, serializer: :user

  # Atributos computados
  attribute :edited do |object|
    object.edited?
  end

  attribute :author_name do |object|
    object.user.name
  end
end
