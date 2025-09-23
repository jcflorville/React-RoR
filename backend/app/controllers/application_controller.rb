class ApplicationController < ActionController::API
  include ApiResponse

  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Tratamento global de exceções JWT
  rescue_from JWT::DecodeError, with: :handle_jwt_error

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name])
  end

  def handle_jwt_error
    render_error("Couldn't find an active session.", nil, :unauthorized)
  end
end
