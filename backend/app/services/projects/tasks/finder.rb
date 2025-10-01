# app/services/projects/tasks/finder.rb
class Projects::Tasks::Finder < BaseService
  def self.call(user:, project:, params: {})
    new(user: user, project: project, params: params).call
  end

  def initialize(user:, project:, params: {})
    @user = user
    @project = project
    @params = params
  end

  def call
    return failure(message: 'Project not found') unless user_owns_project?

    if params[:task_id]
      find_single_task
    else
      find_tasks_collection
    end
  end

  private

  attr_reader :user, :project, :params

  def find_single_task
    task = project.tasks.includes(:project, :user, :comments).find(params[:task_id])
    success(data: task)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found in this project')
  end

  def find_tasks_collection
    tasks = project.tasks.includes(:project, :user, :comments)
    tasks = apply_filters(tasks)
    tasks = apply_search(tasks)
    tasks = apply_ordering(tasks)

    success(data: tasks)
  end

  def user_owns_project?
    project && project.user == user
  end

  def apply_filters(tasks)
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?
    tasks = tasks.where(user_id: params[:assignee_id]) if params[:assignee_id].present?

    if params[:due_date_from].present?
      tasks = tasks.where('due_date >= ?', params[:due_date_from])
    end

    if params[:due_date_to].present?
      tasks = tasks.where('due_date <= ?', params[:due_date_to])
    end

    if params[:overdue] == 'true'
      tasks = tasks.where('due_date < ? AND status != ?', Date.current, 'completed')
    end

    tasks
  end

  def apply_search(tasks)
    return tasks unless params[:search].present?

    tasks.search_by_content(params[:search])
  end

  def apply_ordering(tasks)
    case params[:sort]
    when 'due_date_asc'
      tasks.order(:due_date)
    when 'due_date_desc'
      tasks.order(due_date: :desc)
    when 'priority_desc'
      tasks.order(priority: :desc)
    when 'status'
      tasks.order(:status)
    when 'created_at_desc'
      tasks.order(created_at: :desc)
    else
      tasks.order(:created_at)
    end
  end
end
