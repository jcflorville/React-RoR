# app/services/categories/finder.rb
class Categories::Finder < BaseService
  def self.call(params: {})
    new(params: params).call
  end

  def initialize(params: {})
    @params = params
  end

  def call
    if params[:id]
      find_single_category
    else
      find_categories_collection
    end
  end

  private

  attr_reader :params

  def find_single_category
    category = Category.includes(:projects).find(params[:id])
    success(data: category)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Category not found')
  end

  def find_categories_collection
    categories = Category.includes(:projects)
    categories = apply_search(categories)
    categories = apply_ordering(categories)

    success(data: categories)
  end

  def apply_search(categories)
    return categories unless params[:search].present?

    categories.where('name ILIKE ?', "%#{params[:search]}%")
  end

  def apply_ordering(categories)
    case params[:sort]
    when 'name_desc'
      categories.order(name: :desc)
    when 'created_at_desc'
      categories.order(created_at: :desc)
    else
      categories.order(:name)
    end
  end
end
