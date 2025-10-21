module ApiResponse
  extend ActiveSupport::Concern
  include ApiSerialization
  include ApiPagination

  private

  def render_success(data = nil, message = nil, status = :ok, blueprint: nil)
    response_hash = {
      success: true,
      data: serialize_data(data, blueprint: blueprint)
    }
    response_hash[:message] = message if message.present?

    render json: response_hash, status: status
  end

  def render_error(message, errors = nil, status = :unprocessable_content)
    response_hash = {
      success: false,
      message: message
    }
    response_hash[:errors] = format_errors(errors) if errors.present?

    render json: response_hash, status: status
  end

  def render_auth_success(user, message = 'Authentication successful')
    return render_error('User not found', nil, :unauthorized) if user.nil?

    # Generate refresh token
    user.generate_refresh_token!
    refresh_token = generate_refresh_token_jwt(user)

    render json: {
      success: true,
      data: serialize_data(user, blueprint: UserBlueprint),
      refresh_token: refresh_token,
      message: message
    }, status: :ok
  end

  def render_logout_success
    render_success(nil, nil, :no_content)
  end

  def generate_refresh_token_jwt(user)
    payload = {
      sub: user.id,
      refresh_jti: user.refresh_jti,
      exp: user.refresh_token_expires_at.to_i,
      iat: Time.current.to_i,
      type: 'refresh'
    }
    
    JWT.encode(payload, ENV['DEVISE_JWT_SECRET_KEY'], 'HS256')
  end

  private

  def format_errors(errors)
    case errors
    when ActiveModel::Errors
      errors.as_json
    when Hash
      errors
    when Array
      errors
    else
      [ errors.to_s ]
    end
  end
end
