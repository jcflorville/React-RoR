class ProjectBlueprint < ApplicationBlueprint
  identifier :id

  fields :name, :description, :status, :priority,
         :start_date, :end_date, :created_at, :updated_at

  # Computed fields
  # field :progress_percentage do |project|
  #   project.progress_percentage
  # end

  field :overdue do |project|
    project.overdue?
  end

  field :status_humanized do |project|
    project.status.humanize
  end

  field :priority_humanized do |project|
    project.priority.humanize
  end

  # Conditional associations
  association :tasks, blueprint: TaskBlueprint,
    if: include_condition(:tasks)

  association :categories, blueprint: CategoryBlueprint,
    if: include_condition(:categories)
end
