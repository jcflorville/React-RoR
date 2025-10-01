class Api::V1::Authenticated::CategoriesController < Api::V1::Authenticated::BaseController
  def index
    result = Categories::Finder.call(user: current_user, params: filter_params)

    if result.success?
      render_success(
        serialize_collection(result.data, CategorySerializer),
        result.message
      )
    else
      render_error(result.message, result.errors)
    end
  end

  def show
    result = Categories::Finder.call(user: current_user, params: { id: params[:id] })

    if result.success?
      render_success(
        serialize_resource(result.data, CategorySerializer),
        result.message
      )
    else
      render_error(result.message, result.errors, :not_found)
    end
  end

  def create
    result = Categories::Creator.call(user: current_user, params: category_params)

    if result.success?
      render_success(
        serialize_resource(result.data, CategorySerializer),
        result.message,
        :created
      )
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def update
    result = Categories::Updater.call(user: current_user, category_id: params[:id], params: category_params)

    if result.success?
      render_success(
        serialize_resource(result.data, CategorySerializer),
        result.message
      )
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def destroy
    result = Categories::Destroyer.call(user: current_user, category_id: params[:id])

    if result.success?
      render_success(nil, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :color, :description)
  end

  def filter_params
    params.permit(:search, :sort)
  end

  # Helper methods para serialização
  def serialize_resource(resource, serializer)
    serializer.new(resource).serializable_hash[:data][:attributes]
  end

  def serialize_collection(collection, serializer)
    serializer.new(collection).serializable_hash[:data].map { |item| item[:attributes] }
  end
end
