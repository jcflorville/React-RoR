class UserSerializer < ApplicationSerializer
  attributes :id, :email, :name, :created_at, :updated_at
end
