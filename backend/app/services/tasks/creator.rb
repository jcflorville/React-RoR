# app/services/tasks/creator.rb
class Tasks::Creator < BaseService
  def self.call(user:, params:)
    new(user: user, params: params).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    validation_result = validate_project!
    return validation_result unless validation_result.success?

    create_task
  end

  private

  attr_reader :user, :params

  def validate_project!
    @project = user.projects.find(params[:project_id])
    success(data: @project)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Project not found')
  end

  def create_task
    assignee = find_assignee
    task = @project.tasks.build(task_params)
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

  def task_params
    params.slice(:title, :description, :status, :priority, :due_date).compact
  end
end
