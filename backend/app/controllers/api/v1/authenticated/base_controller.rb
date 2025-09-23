# app/controllers/api/v1/base_controller.rb
class Api::V1::Authenticated::BaseController < ApplicationController
  include ApiResponse

  before_action :authenticate_user!

  respond_to :json

  # Tratamento de exceções
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_errors
  rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized if defined?(Pundit)

  private

  def render_not_found(exception = nil)
    render_error('Resource not found', nil, :not_found)
  end

  def render_validation_errors(exception)
    render_error('Validation failed', exception.record.errors, :unprocessable_content)
  end

  def render_unauthorized
    render_error('Access denied', nil, :forbidden)
  end
end
