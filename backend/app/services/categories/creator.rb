# app/services/categories/creator.rb
class Categories::Creator < BaseService
  def self.call(params:)
    new(params: params).call
  end

  def initialize(params:)
    @params = params
  end

  def call
    create_category
  end

  private

  attr_reader :params

  def create_category
    category = Category.new(category_params)

    if category.save
      success(data: category, message: 'Category created successfully')
    else
      failure(errors: format_errors(category), message: 'Failed to create category')
    end
  end

  def category_params
    params.slice(:name, :color, :description).compact
  end
end
