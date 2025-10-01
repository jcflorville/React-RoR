# app/services/comments/creator.rb
class Comments::Creator < BaseService
  def self.call(user:, params:)
    new(user: user, params: params).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    validate_task!
    create_comment
  end

  private

  attr_reader :user, :params

  def validate_task!
    @task = Task.joins(:project)
                .where(projects: { user: user })
                .find(params[:task_id])
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Task not found')
  end

  def create_comment
    comment = @task.comments.build(comment_params)
    comment.user = user

    if comment.save
      success(data: comment, message: 'Comment created successfully')
    else
      failure(errors: format_errors(comment), message: 'Failed to create comment')
    end
  end

  def comment_params
    params.slice(:content).compact
  end
end
