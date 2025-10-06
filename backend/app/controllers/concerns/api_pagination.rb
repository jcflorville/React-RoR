module ApiPagination
  extend ActiveSupport::Concern

  private

  def render_pagination(collection, serializer_class = nil)
    serializer = serializer_class || infer_serializer_for_model(collection)

    render json: {
      success: true,
      data: serializer ? serialize_collection(collection, serializer) : collection,
      meta: pagination_meta(collection)
    }
  end

  def pagination_meta(collection)
    {
      current_page: collection.respond_to?(:current_page) ? collection.current_page : 1,
      per_page: collection.respond_to?(:limit_value) ? collection.limit_value : collection.size,
      total_pages: collection.respond_to?(:total_pages) ? collection.total_pages : 1,
      total_count: collection.respond_to?(:total_count) ? collection.total_count : collection.size
    }
  end
end
