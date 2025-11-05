class Api::V1::Authenticated::NotificationStreamController < Api::V1::Authenticated::BaseController
  include ActionController::Live

  # Skip default authentication to handle token from query param
  skip_before_action :authenticate_user!
  before_action :authenticate_from_token!

  # GET /api/v1/notification_stream?token=xxx
  def index
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['X-Accel-Buffering'] = 'no' # Disable nginx buffering

    sse = SSE.new(response.stream, retry: 300, event: 'notification')

    begin
      # Send initial connection confirmation
      sse.write({ type: 'connected', timestamp: Time.current.iso8601 }, event: 'ping')

      # Keep connection alive with heartbeat
      loop do
        # Send heartbeat every 15 seconds to keep connection alive
        sse.write({ type: 'heartbeat', timestamp: Time.current.iso8601 }, event: 'ping')

        # Check for new notifications (created in last 20 seconds to catch anything sent between heartbeats)
        notifications = current_user.notifications
          .where('created_at > ?', 20.seconds.ago)
          .unread
          .recent
          .includes(:actor, :notifiable)
          .limit(10)

        if notifications.any?
          notifications.each do |notification|
            data = NotificationBlueprint.render_as_hash(
              notification,
              include: [ :actor, :notifiable ]
            )
            sse.write(data, event: 'notification')
          end
        end

        sleep 15
      end
    rescue IOError, Errno::EPIPE => e
      # Client disconnected
      Rails.logger.info "[NotificationStream] Client disconnected: #{e.message}"
    ensure
      sse.close
    end
  end

  private

  # Authenticate user from token query parameter
  # EventSource API doesn't support custom headers, so we accept token via query param
  def authenticate_from_token!
    token = params[:token]

    unless token
      render json: { error: 'Missing token parameter' }, status: :unauthorized
      return
    end

    # Decode JWT token
    begin
      secret = Rails.application.credentials.devise_jwt_secret_key
      decoded_token = JWT.decode(token, secret, true, { algorithm: 'HS256' })
      user_id = decoded_token.first['sub']

      @current_user = User.find(user_id)
    rescue JWT::DecodeError, JWT::ExpiredSignature
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
