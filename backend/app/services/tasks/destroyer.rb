# app/services/tasks/destroyer.rb
class Tasks::Destroyer < BaseService
  def self.call(user:, task_id:)
    new(user: user, task_id: task_id).call
  end

  def initialize(user:, task_id:)
    @user = user
    @task_id = task_id
  end

  def call
    task_result = find_task!
    return task_result if task_result&.failure?

    destroy_task
  end

  private

  attr_reader :user, :task_id

  def find_task!
    @task = Task.joins(:project)
                .where(projects: { user: user })
                .find(task_id)
    nil # Return nil if successful
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found')
  end

  def destroy_task
    if @task.destroy
      success(message: 'Task deleted successfully')
    else
      failure(errors: format_errors(@task), message: 'Failed to delete task')
    end
  end
end
