module ApiResponse
  extend ActiveSupport::Concern
  include ApiSerialization
  include ApiPagination

  private

  def render_success(data = nil, message = nil, status = :ok)
    response_hash = {
      success: true,
      data: serialize_data(data)
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

    render_success(
      UserSerializer.new(user).serializable_hash[:data][:attributes],
      message
    )
  end

  def render_logout_success
    render_success(nil, nil, :no_content)
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
