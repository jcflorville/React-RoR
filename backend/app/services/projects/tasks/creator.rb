# app/services/projects/tasks/creator.rb
class Projects::Tasks::Creator < BaseService
  def self.call(user:, project:, params:)
    new(user: user, project: project, params: params).call
  end

  def initialize(user:, project:, params:)
    @user = user
    @project = project
    @params = params
  end

  def call
    return failure(message: 'Project not found') unless user_owns_project?

    create_task
  end

  private

  attr_reader :user, :project, :params

  def create_task
    assignee = find_assignee
    task = project.tasks.build(task_params)
    task.user = assignee

    if task.save
      success(data: task, message: 'Task created successfully')
    else
      failure(errors: format_errors(task), message: 'Failed to create task')
    end
  end

  def find_assignee
    params[:user_id] ? User.find(params[:user_id]) : user
  rescue ActiveRecord::RecordNotFound
    user # fallback to current user if assignee not found
  end

  def user_owns_project?
    project && project.user == user
  end

  def task_params
    params.slice(:title, :description, :status, :priority, :due_date).compact
  end
end
