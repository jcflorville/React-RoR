# app/services/tasks/updater.rb
class Tasks::Updater < BaseService
  def self.call(user:, task_id:, params:)
    new(user: user, task_id: task_id, params: params).call
  end

  def initialize(user:, task_id:, params:)
    @user = user
    @task_id = task_id
    @params = params
  end

  def call
    find_result = find_task!
    return find_result unless find_result.success?

    update_task
  end

  private

  attr_reader :user, :task_id, :params

  def find_task!
    @task = Task.joins(:project)
                .where(projects: { user: user })
                .find(task_id)
    success(data: @task)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found')
  end

  def update_task
    update_assignee if params[:user_id]

    if @task.update(task_params)
      success(data: @task, message: 'Task updated successfully')
    else
      failure(errors: format_errors(@task), message: 'Failed to update task')
    end
  end

  def update_assignee
    assignee = User.find(params[:user_id])
    @task.user = assignee
  rescue ActiveRecord::RecordNotFound
    # Continue without updating assignee if user not found
  end

  def task_params
    params.slice(:title, :description, :status, :priority, :due_date).compact
  end
end
