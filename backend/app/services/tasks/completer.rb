# app/services/tasks/completer.rb
class Tasks::Completer < BaseService
  def self.call(user:, task_id:)
    new(user: user, task_id: task_id).call
  end

  def initialize(user:, task_id:)
    @user = user
    @task_id = task_id
  end

  def call
    find_result = find_task!
    return find_result unless find_result.success?

    complete_task
  end

  private

  attr_reader :user, :task_id

  def find_task!
    @task = Task.joins(:project)
                .where(projects: { user: user })
                .find(task_id)
    success(data: @task)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found')
  end

  def complete_task
    if @task.update(status: :completed, completed_at: Time.current)
      success(data: @task, message: 'Task completed successfully')
    else
      failure(errors: format_errors(@task), message: 'Failed to complete task')
    end
  end
end
