class CommentBlueprint < ApplicationBlueprint
  identifier :id

  fields :content, :edited_at, :created_at, :updated_at

  # Computed fields
  field :edited do |comment|
    comment.edited?
  end

  field :author_name do |comment|
    comment.user.name
  end

  # Conditional associations
  association :task, blueprint: TaskBlueprint,
    if: include_condition(:task)

  association :user, blueprint: UserBlueprint,
    if: include_condition(:user)
end
