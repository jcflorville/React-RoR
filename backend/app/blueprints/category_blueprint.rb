class CategoryBlueprint < ApplicationBlueprint
  identifier :id

  fields :name, :color, :description, :created_at, :updated_at

  # Conditional association - only included when requested
  association :projects, blueprint: ProjectBlueprint,
    if: include_condition(:projects)
end
