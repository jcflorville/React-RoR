# app/services/comments/finder.rb
class Comments::Finder < BaseService
  def self.call(user:, params: {})
    new(user: user, params: params).call
  end

  def initialize(user:, params: {})
    @user = user
    @params = params
  end

  def call
    find_comments_collection
  end

  private

  attr_reader :user, :params

  def find_comments_collection
    comments = user.comments.includes(:task, :user)
    comments = apply_filters(comments)
    comments = apply_search(comments)
    comments = apply_ordering(comments)

    success(data: comments)
  end

  def apply_filters(comments)
    comments = comments.where(task_id: params[:task_id]) if params[:task_id].present?
    comments
  end

  def apply_search(comments)
    return comments unless params[:search].present?

    comments.where('content ILIKE ?', "%#{params[:search]}%")
  end

  def apply_ordering(comments)
    case params[:sort]
    when 'created_at_asc'
      comments.order(:created_at)
    else
      comments.order(created_at: :desc)
    end
  end
end
