# app/services/comments/updater.rb
class Comments::Updater < BaseService
  def self.call(user:, comment_id:, params:)
    new(user: user, comment_id: comment_id, params: params).call
  end

  def initialize(user:, comment_id:, params:)
    @user = user
    @comment_id = comment_id
    @params = params
  end

  def call
    find_comment!
    update_comment
  end

  private

  attr_reader :user, :comment_id, :params

  def find_comment!
    @comment = user.comments.find(comment_id)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Comment not found')
  end

  def update_comment
    if @comment.update(comment_params)
      success(data: @comment, message: 'Comment updated successfully')
    else
      failure(errors: format_errors(@comment), message: 'Failed to update comment')
    end
  end

  def comment_params
    params.slice(:content).compact
  end
end
