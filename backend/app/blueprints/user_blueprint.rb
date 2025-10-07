class UserBlueprint < ApplicationBlueprint
  identifier :id

  fields :email, :name, :created_at, :updated_at
end
