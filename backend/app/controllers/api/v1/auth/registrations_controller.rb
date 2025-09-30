class Api::V1::Auth::RegistrationsController < Devise::RegistrationsController
  include ApiResponse

  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render_auth_success(resource, 'Account created successfully')
    else
      render_error('Registration failed', resource.errors.full_messages, :unprocessable_content)
    end
  end
end
