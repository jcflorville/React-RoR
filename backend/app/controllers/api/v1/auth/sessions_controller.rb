class Api::V1::Auth::SessionsController < Devise::SessionsController
  include ApiResponse
  respond_to :json

  def create
    self.resource = warden.authenticate(auth_options)
    if resource
      sign_in(resource_name, resource)
      render_auth_success(resource, 'Logged in successfully')
    else
      render_error('Invalid Email or password.', nil, :unauthorized)
    end
  end

  private

  def respond_to_on_destroy
    render_logout_success
  end
end
