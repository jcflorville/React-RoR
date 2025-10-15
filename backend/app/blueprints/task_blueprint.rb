class TaskBlueprint < ApplicationBlueprint
  identifier :id

  fields :title, :description, :status, :priority, :due_date,
         :completed_at, :created_at, :updated_at

  # Computed fields
  # field :overdue do |task|
  #   task.overdue?
  # end

  # field :days_until_due do |task|
  #   task.days_until_due
  # end

  # Conditional associations
  association :project, blueprint: ProjectBlueprint,
    if: include_condition(:project)

  association :user, blueprint: UserBlueprint,
    if: include_condition(:user)

  association :comments, blueprint: CommentBlueprint,
    if: include_condition(:comments)
end
