# app/services/tasks/overdue_finder.rb
class Tasks::OverdueFinder < BaseService
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

    success(data: tasks, message: 'Overdue tasks')
  end

  private

  attr_reader :user, :params

  def base_scope
    Task.joins(:project)
        .where(projects: { user: user })
        .where('due_date < ? AND status != ?', Date.current, 'completed')
        .includes(:project, :user, :comments)
  end

  def apply_filters(tasks)
    tasks = tasks.where(status: params[:status]) if params[:status].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?
    tasks = tasks.where(project_id: params[:project_id]) if params[:project_id].present?
    tasks = tasks.where(user_id: params[:assignee_id]) if params[:assignee_id].present?

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
      tasks.order(:due_date) # For overdue, default to due_date
    end
  end
end
