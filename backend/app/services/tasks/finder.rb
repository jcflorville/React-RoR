# app/services/tasks/finder.rb
class Tasks::Finder < BaseService
  def self.call(user:, params: {})
    new(user: user, params: params).call
  end

  def initialize(user:, params: {})
    @user = user
    @params = params
  end

  def call
    if params[:id]
      find_single_task
    else
      find_tasks_collection
    end
  end

  private

  attr_reader :user, :params

  def find_single_task
    task = base_scope.find(params[:id])
    success(data: task)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found')
  end

  def find_tasks_collection
    tasks = base_scope
    tasks = apply_filters(tasks)
    tasks = apply_search(tasks)
    tasks = apply_ordering(tasks)

    success(data: tasks)
  end

  def base_scope
    Task.joins(:project)
        .where(projects: { user: user })
        .includes(:project, :user, :comments)
  end

  def apply_filters(tasks)
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?
    tasks = tasks.where(project_id: params[:project_id]) if params[:project_id].present?
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
