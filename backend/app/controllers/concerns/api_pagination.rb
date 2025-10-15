module ApiPagination
  extend ActiveSupport::Concern

  private

  def render_pagination(collection, blueprint_class = nil)
    render json: {
      success: true,
      data: serialize_data(collection),
      meta: pagination_meta(collection)
    }
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_pages: collection.total_pages,
      total_count: collection.total_count,
      next_page: collection.next_page
    }
  end
end
