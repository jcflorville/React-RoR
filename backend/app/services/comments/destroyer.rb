# app/services/comments/destroyer.rb
class Comments::Destroyer < BaseService
  def self.call(user:, comment_id:)
    new(user: user, comment_id: comment_id).call
  end

  def initialize(user:, comment_id:)
    @user = user
    @comment_id = comment_id
  end

  def call
    find_comment!
    destroy_comment
  end

  private

  attr_reader :user, :comment_id

  def find_comment!
    @comment = user.comments.find(comment_id)
  rescue ActiveRecord::RecordNotFound
    failure(message: 'Comment not found')
  end

  def destroy_comment
    if @comment.destroy
      success(message: 'Comment deleted successfully')
    else
      failure(errors: format_errors(@comment), message: 'Failed to delete comment')
    end
  end
end
