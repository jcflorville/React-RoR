module ApiSerialization
  extend ActiveSupport::Concern

  private

  def serialize_data(data, blueprint: nil)
    return nil if data.nil?

    # Non-ActiveRecord data passes through as-is
    return data unless data.is_a?(ActiveRecord::Base) || data.is_a?(ActiveRecord::Relation)

    # Use provided blueprint or infer from model name
    blueprint_class = blueprint || infer_blueprint(data)

    # Parse includes from query params
    requested_includes = parse_include_params(params[:include])

    # Render with Blueprinter - Rails automatically stringifies keys in render json:
    blueprint_class.render_as_hash(data, include: requested_includes)
  rescue NameError => e
    # Fallback if blueprint doesn't exist
    Rails.logger.warn(
      "Blueprint not found for '#{data.class.name}': #{e.message}. " \
      "Ensure a '#{data.class.name}Blueprint' exists in app/blueprints/ and is named correctly."
    )
    data
  end

  def infer_blueprint(data)
    model_name = if data.respond_to?(:model_name)
      data.model_name.name
    elsif data.respond_to?(:klass)
      data.klass.model_name.name
    else
      data.class.name
    end

    "#{model_name}Blueprint".constantize
  end

  def parse_include_params(include_param)
    return [] if include_param.blank?
    include_param.split(',').map(&:strip).map(&:to_sym)
  end
end
