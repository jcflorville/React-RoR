class Api::V1::Authenticated::CommentsController < Api::V1::Authenticated::BaseController
  def index
    result = Comments::Finder.call(user: current_user, params: filter_params)

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors)
    end
  end

  def create
    result = Comments::Creator.call(user: current_user, params: comment_params)

    if result.success?
      # Trigger notifications for mentions and task owner
      Notifications::CommentNotifier.call(comment: result.data, actor: current_user)

      render_success(
        serialize_data(result.data),
        result.message,
        :created
      )
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def update
    result = Comments::Updater.call(user: current_user, comment_id: params[:id], params: comment_params)

    if result.success?
      render_success(
        serialize_data(result.data),
        result.message
      )
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  def destroy
    result = Comments::Destroyer.call(user: current_user, comment_id: params[:id])

    if result.success?
      render_success(nil, result.message)
    else
      render_error(result.message, result.errors, :unprocessable_content)
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :task_id)
  end

  def filter_params
    params.permit(:search, :task_id, :project_id, :sort)
  end
end
