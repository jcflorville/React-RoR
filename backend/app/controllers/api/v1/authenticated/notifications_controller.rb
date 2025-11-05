class Api::V1::Authenticated::NotificationsController < Api::V1::Authenticated::BaseController
  # GET /api/v1/notifications
  def index
    notifications = current_user.notifications
                                .includes(:actor, :notifiable)
                                .recent
                                .page(params[:page])
                                .per(params[:per_page] || 20)

    # Apply filters
    notifications = notifications.unread if params[:unread] == 'true'
    notifications = notifications.by_event_type(params[:event_type]) if params[:event_type].present?

    render_pagination(
      notifications,
      'Notifications retrieved successfully'
    )
  end

  # GET /api/v1/notifications/unread_count
  def unread_count
    count = current_user.notifications.unread.count

    render_success(
      { unread_count: count },
      'Unread count retrieved successfully'
    )
  end

  # GET /api/v1/notifications/:id
  def show
    notification = current_user.notifications.find(params[:id])

    render_success(
      serialize_data(notification),
      'Notification retrieved successfully'
    )
  end

  # PATCH /api/v1/notifications/:id/mark_as_read
  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    render_success(
      serialize_data(notification),
      'Notification marked as read'
    )
  end

  # PATCH /api/v1/notifications/:id/mark_as_unread
  def mark_as_unread
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_unread!

    render_success(
      serialize_data(notification),
      'Notification marked as unread'
    )
  end

  # POST /api/v1/notifications/mark_all_as_read
  def mark_all_as_read
    current_user.notifications.unread.find_each(&:mark_as_read!)

    render_success(
      nil,
      'All notifications marked as read'
    )
  end

  # DELETE /api/v1/notifications/:id
  def destroy
    notification = current_user.notifications.find(params[:id])
    notification.destroy!

    render_success(nil, 'Notification deleted successfully')
  end
end
