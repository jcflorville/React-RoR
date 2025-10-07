class Api::V1::Authenticated::TasksController < Api::V1::Authenticated::BaseController
  # Operações globais de tasks (cross-project) usando Command Objects

  def index
    result = Tasks::Finder.call(user: current_user, params: filter_params)

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
    result = Tasks::Finder.call(user: current_user, params: { id: params[:id] })

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
    result = Tasks::Creator.call(user: current_user, params: task_params)

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
    result = Tasks::Updater.call(
      user: current_user,
      task_id: params[:id],
      params: task_params
    )

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
    result = Tasks::Destroyer.call(user: current_user, task_id: params[:id])

    if result.success?
      render_success(nil, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  # Operações específicas para rotas globais
  def mine
    result = Tasks::MyTasksFinder.call(user: current_user, params: filter_params)

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors)
    end
  end

  def overdue
    result = Tasks::OverdueFinder.call(user: current_user, params: filter_params)

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors)
    end
  end

  def complete
    result = Tasks::Completer.call(user: current_user, task_id: params[:id])

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def reopen
    result = Tasks::Reopener.call(user: current_user, task_id: params[:id])

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  private

  def task_params
    params.require(:task).permit(
      :title, :description, :status, :priority, :due_date, :project_id, :user_id
    )
  end

  def filter_params
    params.permit(
      :search, :status, :priority, :project_id, :assignee_id,
      :due_date_from, :due_date_to, :overdue, :sort
    )
  end
end
