# app/services/projects/tasks/destroyer.rb
class Projects::Tasks::Destroyer < BaseService
  def self.call(user:, project:, task_id:)
    new(user: user, project: project, task_id: task_id).call
  end

  def initialize(user:, project:, task_id:)
    @user = user
    @project = project
    @task_id = task_id
  end

  def call
    return failure(message: 'Project not found') unless user_owns_project?

    find_task!
    destroy_task
  end

  private

  attr_reader :user, :project, :task_id

  def find_task!
    @task = project.tasks.find(task_id)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found in this project')
  end

  def destroy_task
    if @task.destroy
      success(message: 'Task deleted successfully')
    else
      failure(errors: format_errors(@task), message: 'Failed to delete task')
    end
  end

  def user_owns_project?
    project && project.user == user
  end
end
