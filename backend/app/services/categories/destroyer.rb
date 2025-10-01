# app/services/categories/destroyer.rb
class Categories::Destroyer < BaseService
  def self.call(category_id:)
    new(category_id: category_id).call
  end

  def initialize(category_id:)
    @category_id = category_id
  end

  def call
    find_category!
    destroy_category
  end

  private

  attr_reader :category_id

  def find_category!
    @category = Category.find(category_id)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Category not found')
  end

  def destroy_category
    if @category.destroy
      success(message: 'Category deleted successfully')
    else
      failure(errors: format_errors(@category), message: 'Failed to delete category')
    end
  end
end
