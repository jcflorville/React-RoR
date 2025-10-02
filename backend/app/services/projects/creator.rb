# app/services/projects/creator.rb
class Projects::Creator < BaseService
  def self.call(user:, params:)
    new(user: user, params: params).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    create_project
  end

  private

  attr_reader :user, :params

  def create_project
    project = user.projects.build(project_params)

    if project.save
      associate_categories(project) if params[:category_ids].present?
      success(data: project, message: 'Project created successfully')
    else
      failure(errors: format_errors(project), message: 'Failed to create project')
    end
  end

  def associate_categories(project)
    categories = Category.where(id: params[:category_ids])
    project.categories = categories
  end

  def project_params
    params.slice(:name, :description, :status, :priority, :start_date, :end_date).compact
  end
end
