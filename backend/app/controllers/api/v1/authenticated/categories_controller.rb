class Api::V1::Authenticated::CategoriesController < Api::V1::Authenticated::BaseController
  def index
    result = Categories::Finder.call(params: filter_params)

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors)
    end
  end

  def show
    result = Categories::Finder.call(params: { id: params[:id] })

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors, :not_found)
    end
  end

  def create
    result = Categories::Creator.call(params: category_params)

    if result.success?
      render_success(
        serialize_data(result.data),
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
        serialize_data(result.data),
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
end
