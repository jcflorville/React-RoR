# app/services/projects/finder.rb
class Projects::Finder < BaseService
  def self.call(user:, params: {})
    new(user: user, params: params).call
  end

  def initialize(user:, params: {})
    @user = user
    @params = params
  end

  def call
    if params[:id]
      find_single_project
    else
      find_projects_collection
    end
  end

  private

  attr_reader :user, :params

  def find_single_project
    project = user.projects.includes(:tasks, :categories).find(params[:id])
    success(data: project)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Project not found')
  end

  def find_projects_collection
    projects = user.projects.includes(:tasks, :categories)
    projects = apply_filters(projects)
    projects = apply_search(projects)
    projects = apply_ordering(projects)

    success(data: projects)
  end

  def apply_filters(projects)
    projects = projects.by_status(params[:status]) if params[:status].present?
    projects = projects.by_priority(params[:priority]) if params[:priority].present?

    if params[:category_id].present?
      projects = projects.joins(:categories).where(categories: { id: params[:category_id] })
    end

    projects
  end

  def apply_search(projects)
    return projects if params[:search].blank?

    projects.search_by_content(params[:search])
  end

  def apply_ordering(projects)
    case params[:sort]
    when 'name_asc'
      projects.order(:name)
    when 'name_desc'
      projects.order(name: :desc)
    when 'priority_desc'
      projects.order(priority: :desc)
    when 'status'
      projects.order(:status)
    when 'created_at_desc'
      projects.order(created_at: :desc)
    else
      projects.order(:created_at)
    end
  end
end
