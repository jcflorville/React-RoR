module ApiResponse
  extend ActiveSupport::Concern

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

  def render_pagination(collection, serializer_class = nil)
    serializer = serializer_class || infer_serializer(collection)

    render json: {
      success: true,
      data: serializer ? serialize_collection(collection, serializer) : collection,
      meta: pagination_meta(collection)
    }
  end

  # Para respostas de autenticação
  def render_auth_success(user, message = 'Authentication successful')
    return render_error('User not found', nil, :unauthorized) if user.nil?

    render_success(
      UserSerializer.new(user).serializable_hash[:data][:attributes],
      message
    )
  end

  # Para logout
  def render_logout_success
    render_success(nil, nil, :no_content)
  end

  def serialize_data(data)
    return nil if data.nil?

    case data
    when ActiveRecord::Base, ActiveRecord::Relation
      # Auto-detect serializer for ActiveRecord objects
      serializer_class = infer_serializer_for_model(data)
      if serializer_class
        if data.respond_to?(:each) # Collection
          serialize_collection(data, serializer_class)
        else # Single resource
          serialize_resource(data, serializer_class)
        end
      else
        data
      end
    when JSONAPI::Serializer
      # Already a serializer instance
      data.serializable_hash[:data]
    else
      data
    end
  end

  def serialize_resource(resource, serializer_class)
    serializer_class.new(resource).serializable_hash[:data][:attributes]
  end

  def serialize_collection(collection, serializer_class)
    serializer_class.new(collection).serializable_hash[:data].map { |item| item[:attributes] }
  end

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

  def pagination_meta(collection)
    {
      current_page: collection.respond_to?(:current_page) ? collection.current_page : 1,
      per_page: collection.respond_to?(:limit_value) ? collection.limit_value : collection.size,
      total_pages: collection.respond_to?(:total_pages) ? collection.total_pages : 1,
      total_count: collection.respond_to?(:total_count) ? collection.total_count : collection.size
    }
  end

  def infer_serializer_for_model(data)
    model_class = data.respond_to?(:klass) ? data.klass : data.class
    model_name = model_class.name
    "#{model_name}Serializer".constantize
  rescue NameError
    nil
  end

  def infer_serializer(collection)
    return nil if collection.empty?

    model_name = collection.first.class.name
    "#{model_name}Serializer".constantize
  rescue NameError
    nil
  end
end
