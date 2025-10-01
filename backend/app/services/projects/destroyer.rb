# app/services/projects/destroyer.rb
class Projects::Destroyer < BaseService
  def self.call(user:, project_id:)
    new(user: user, project_id: project_id).call
  end

  def initialize(user:, project_id:)
    @user = user
    @project_id = project_id
  end

  def call
    find_result = find_project!
    return find_result unless find_result.success?

    destroy_project
  end

  private

  attr_reader :user, :project_id

  def find_project!
    @project = user.projects.find(project_id)
    success(data: @project)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Project not found')
  end

  def destroy_project
    if @project.destroy
      success(message: 'Project deleted successfully')
    else
      failure(errors: format_errors(@project), message: 'Failed to delete project')
    end
  end
end
