# app/services/categories/updater.rb
class Categories::Updater < BaseService
  def self.call(category_id:, params:)
    new(category_id: category_id, params: params).call
  end

  def initialize(category_id:, params:)
    @category_id = category_id
    @params = params
  end

  def call
    find_category!
    update_category
  end

  private

  attr_reader :category_id, :params

  def find_category!
    @category = Category.find(category_id)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Category not found')
  end

  def update_category
    if @category.update(category_params)
      success(data: @category, message: 'Category updated successfully')
    else
      failure(errors: format_errors(@category), message: 'Failed to update category')
    end
  end

  def category_params
    params.slice(:name, :color, :description).compact
  end
end
