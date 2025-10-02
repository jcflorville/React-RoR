# app/services/projects/updater.rb
class Projects::Updater < BaseService
  def self.call(user:, project_id:, params:)
    new(user: user, project_id: project_id, params: params).call
  end

  def initialize(user:, project_id:, params:)
    @user = user
    @project_id = project_id
    @params = params
  end

  def call
    find_result = find_project!
    return find_result unless find_result.success?

    update_project
  end

  private

  attr_reader :user, :project_id, :params

  def find_project!
    @project = user.projects.find(project_id)
    success(data: @project)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Project not found')
  end

  def update_project
    if @project.update(project_params)
      associate_categories if params[:category_ids].present?
      success(data: @project, message: 'Project updated successfully')
    else
      failure(errors: format_errors(@project), message: 'Failed to update project')
    end
  end

  def associate_categories
    categories = Category.where(id: params[:category_ids])
    @project.categories = categories
  end

  def project_params
    params.slice(:name, :description, :status, :priority, :start_date, :end_date).compact
  end
end
