class Api::V1::Authenticated::ProfilesController < Api::V1::Authenticated::BaseController
  include ApiResponse

  before_action :authenticate_user!
  respond_to :json

  def show
    render_success(
      UserSerializer.new(current_user).serializable_hash[:data][:attributes]
    )
  end

  def update
    if current_user.update(user_params)
      render_success(
        UserSerializer.new(current_user).serializable_hash[:data][:attributes],
        'Profile updated successfully'
      )
    else
      render_error(
        'Failed to update profile',
        current_user.errors,
        :unprocessable_content
      )
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
