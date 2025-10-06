module ApiSerialization
  extend ActiveSupport::Concern

  private

  def serialize_data(data)
    return nil if data.nil?

    case data
    when ActiveRecord::Base, ActiveRecord::Relation
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
      data.serializable_hash[:data]
    else
      data
    end
  end

  def serialize_resource(resource, serializer_class)
    requested_includes = parse_include_params(params[:include])

    # Usar tanto params quanto include para forçar dados completos
    serialized = serializer_class.new(
      resource,
      params: { include: requested_includes },
      include: requested_includes
    ).serializable_hash

    # Fazer o flatten das relationships de forma mais eficiente
    data = serialized[:data][:attributes]

    if serialized[:data][:relationships].present? && serialized[:included].present?
      relationships = serialized[:data][:relationships]
      included = serialized[:included]

      # Criar um hash para lookup O(1) em vez de find O(n)
      included_lookup = included.index_by { |item| "#{item[:type]}_#{item[:id]}" }

      relationships.each do |rel_name, rel_data|
        if rel_data[:data].present?
          rel_items = rel_data[:data].filter_map do |ref|
            key = "#{ref[:type]}_#{ref[:id]}"
            included_lookup[key]&.dig(:attributes)
          end

          data[rel_name] = rel_items unless rel_items.empty?
        end
      end
    end

    data
  end

  def serialize_collection(collection, serializer_class)
    requested_includes = parse_include_params(params[:include])

    serialized = serializer_class.new(
      collection,
      params: { include: requested_includes }
    ).serializable_hash

    serialized[:data].map { |item| item[:attributes] }
  end

  def parse_include_params(include_param)
    return [] if include_param.blank?
    include_param.split(',').map(&:strip).map(&:to_sym)
  end

  def infer_serializer_for_model(data)
    return nil if data.nil?

    if data.respond_to?(:empty?) && data.empty?
      return nil
    end

    model_class = if data.respond_to?(:klass)
      data.klass
    elsif data.respond_to?(:each)
      data.first&.class
    else
      data.class
    end

    return nil unless model_class

    "#{model_class.name}Serializer".constantize
  rescue NameError
    nil
  end
end
