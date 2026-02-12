class DrawingBlueprint < ApplicationBlueprint
  identifier :id

  fields :title, :canvas_data, :lock_version, :created_at, :updated_at

  association :user, blueprint: UserBlueprint,
              if: include_condition(:user)
end
