class Api::V1::Authenticated::WebhookSubscriptionsController < Api::V1::Authenticated::BaseController
  # GET /api/v1/webhook_subscriptions
  def index
    subscriptions = current_user.webhook_subscriptions.order(created_at: :desc)

    # Apply filters
    subscriptions = subscriptions.active if params[:active] == 'true'
    subscriptions = subscriptions.inactive if params[:active] == 'false'

    render_success(
      serialize_data(subscriptions),
      'Webhook subscriptions retrieved successfully'
    )
  end

  # GET /api/v1/webhook_subscriptions/:id
  def show
    subscription = current_user.webhook_subscriptions.find(params[:id])

    render_success(
      serialize_data(subscription),
      'Webhook subscription retrieved successfully'
    )
  end

  # POST /api/v1/webhook_subscriptions
  def create
    subscription = current_user.webhook_subscriptions.build(webhook_params)

    if subscription.save
      # Pass show_secret option to blueprint via options hash
      data = WebhookSubscriptionBlueprint.render_as_hash(subscription, { show_secret: true })
      render_success(
        data,
        'Webhook subscription created successfully',
        :created
      )
    else
      render_error(
        'Failed to create webhook subscription',
        format_errors(subscription.errors),
        :unprocessable_content
      )
    end
  end

  # PATCH /api/v1/webhook_subscriptions/:id
  def update
    subscription = current_user.webhook_subscriptions.find(params[:id])

    if subscription.update(webhook_params)
      render_success(
        serialize_data(subscription),
        'Webhook subscription updated successfully'
      )
    else
      render_error(
        'Failed to update webhook subscription',
        format_errors(subscription.errors),
        :unprocessable_content
      )
    end
  end

  # DELETE /api/v1/webhook_subscriptions/:id
  def destroy
    subscription = current_user.webhook_subscriptions.find(params[:id])
    subscription.destroy!

    render_success(nil, 'Webhook subscription deleted successfully')
  end

  # POST /api/v1/webhook_subscriptions/:id/enable
  def enable
    subscription = current_user.webhook_subscriptions.find(params[:id])
    subscription.enable!

    render_success(
      serialize_data(subscription),
      'Webhook subscription enabled'
    )
  end

  # POST /api/v1/webhook_subscriptions/:id/disable
  def disable
    subscription = current_user.webhook_subscriptions.find(params[:id])
    subscription.disable!

    render_success(
      serialize_data(subscription),
      'Webhook subscription disabled'
    )
  end

  private

  def webhook_params
    params.require(:webhook_subscription).permit(:name, :url, events: [])
  end
end
