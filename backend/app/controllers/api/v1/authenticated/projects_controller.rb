class Api::V1::Authenticated::ProjectsController < Api::V1::Authenticated::BaseController
  def index
    result = Projects::Finder.call(user: current_user, params: filter_params)

    if result.success?
      render_pagination(result.data, result.message)
    else
      render_error(result.message, result.errors)
    end
  end

  def show
    result = Projects::Finder.call(user: current_user, params: { id: params[:id] })

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors, :not_found)
    end
  end

  def create
    result = Projects::Creator.call(user: current_user, params: project_params)

    if result.success?
      render_success(result.data, result.message, :created)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def update
    result = Projects::Updater.call(user: current_user, project_id: params[:id], params: project_params)

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def destroy
    result = Projects::Destroyer.call(user: current_user, project_id: params[:id])

    if result.success?
      render_success(nil, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  private

  def project_params
    params.require(:project).permit(
      :name, :description, :status, :priority, :start_date, :end_date,
      category_ids: []
    )
  end

  def filter_params
    params.permit(:search, :status, :priority, :start_date, :end_date, :sort, :page, :per_page)
  end
end
