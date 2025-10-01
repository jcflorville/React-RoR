# app/services/tasks/my_tasks_finder.rb
class Tasks::MyTasksFinder < BaseService
  def self.call(user:, params: {})
    new(user: user, params: params).call
  end

  def initialize(user:, params: {})
    @user = user
    @params = params
  end

  def call
    tasks = base_scope
    tasks = apply_filters(tasks)
    tasks = apply_search(tasks)
    tasks = apply_ordering(tasks)

    success(data: tasks, message: 'Tasks assigned to you')
  end

  private

  attr_reader :user, :params

  def base_scope
    Task.joins(:project)
        .where(projects: { user: user })
        .where(user: user)
        .includes(:project, :user, :comments)
  end

  def apply_filters(tasks)
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?
    tasks = tasks.where(project_id: params[:project_id]) if params[:project_id].present?

    if params[:due_date_from].present?
      tasks = tasks.where('due_date >= ?', params[:due_date_from])
    end

    if params[:due_date_to].present?
      tasks = tasks.where('due_date <= ?', params[:due_date_to])
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
