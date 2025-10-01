# app/services/projects/tasks/updater.rb
class Projects::Tasks::Updater < BaseService
  def self.call(user:, project:, task_id:, params:)
    new(user: user, project: project, task_id: task_id, params: params).call
  end

  def initialize(user:, project:, task_id:, params:)
    @user = user
    @project = project
    @task_id = task_id
    @params = params
  end

  def call
    return failure(message: 'Project not found') unless user_owns_project?

    find_task!
    update_task
  end

  private

  attr_reader :user, :project, :task_id, :params

  def find_task!
    @task = project.tasks.find(task_id)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found in this project')
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

  def user_owns_project?
    project && project.user == user
  end

  def task_params
    params.slice(:title, :description, :status, :priority, :due_date).compact
  end
end
