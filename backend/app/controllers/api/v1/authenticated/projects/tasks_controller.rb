class Api::V1::Authenticated::Projects::TasksController < Api::V1::Authenticated::BaseController
  before_action :set_project

  def index
    result = Projects::Tasks::Finder.call(
      user: current_user,
      project: @project,
      params: filter_params
    )

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors)
    end
  end

  def show
    result = Projects::Tasks::Finder.call(
      user: current_user,
      project: @project,
      params: { task_id: params[:id] }
    )

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors, :not_found)
    end
  end

  def create
    result = Projects::Tasks::Creator.call(
      user: current_user,
      project: @project,
      params: task_params
    )

    if result.success?
      render_success(result.data, result.message, :created)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def update
    result = Projects::Tasks::Updater.call(
      user: current_user,
      project: @project,
      task_id: params[:id],
      params: task_params
    )

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def destroy
    result = Projects::Tasks::Destroyer.call(
      user: current_user,
      project: @project,
      task_id: params[:id]
    )

    if result.success?
      render_success(nil, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def complete
    result = Projects::Tasks::Completer.call(
      user: current_user,
      project: @project,
      task_id: params[:id]
    )

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def reopen
    result = Projects::Tasks::Reopener.call(
      user: current_user,
      project: @project,
      task_id: params[:id]
    )

    if result.success?
      render_success(result.data, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_error('Project not found', nil, :not_found)
  end

  def task_params
    params.require(:task).permit(
      :title, :description, :status, :priority, :due_date, :user_id
    )
  end

  def filter_params
    params.permit(
      :search, :status, :priority, :assignee_id,
      :due_date_from, :due_date_to, :overdue, :sort
    )
  end
end
