class Api::V1::User::SubscriptionsController < Api::V1::User::ApplicationController
  before_action :set_subscription, only: [:show, :update, :cancel]
  before_action :set_subscriptions, only: [:index]

  def index
    @pagy, @subscriptions = pagy(@subscriptions)
    render json: @subscriptions
  end

  def show
    render json: @subscription
  end

  def create
    pundit_authorize(Subscription.new)

    organizer = Subscription::CreateSubscriptionOrganizer.call(
      current_user: current_user,
      subscription_params: subscription_params
    )

    if organizer.success? && (organizer.subscription.status == 'active' || organizer.subscription.plan.razorpay?)
      render json: organizer.subscription
    elsif organizer.success? && organizer.subscription.plan.stripe? && organizer.stripe_subscription.status == 'incomplete'
      stripe_invoice = Stripe::Invoice.retrieve(organizer.stripe_subscription.latest_invoice)
      payment_intent = Stripe::PaymentIntent.retrieve(stripe_invoice.payment_intent)
      render json: { payment_intent: payment_intent.id, client_secret: payment_intent.client_secret }, status: :payment_required
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  def update
    organizer = Subscription::UpdateSubscriptionOrganizer.call(
      current_user: current_user,
      subscription: @subscription,
      subscription_params: subscription_params
    )

    if organizer.success? && (organizer.subscription.status == 'active' || organizer.subscription.plan.razorpay?)
      render json: @subscription
    elsif organizer.success? && organizer.subscription.plan.stripe? && organizer.stripe_subscription.status == 'incomplete'
      stripe_invoice = Stripe::Invoice.retrieve(organizer.stripe_subscription.latest_invoice)
      payment_intent = Stripe::PaymentIntent.retrieve(stripe_invoice.payment_intent)
      render json: { payment_intent: payment_intent.id, client_secret: payment_intent.client_secret }, status: :payment_required
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  def cancel
    interactor = Subscription::CancelSubscription.call(
      current_user: current_user,
      subscription: @subscription,
      cancel_params: cancel_params
    )

    if interactor.success?
      render json: @subscription
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error), status: :unprocessable_entity
    end
  end

  private

    def set_subscription
      @subscription = pundit_scope(Subscription).find(params[:id])
      pundit_authorize(@subscription) if @subscription
    end

    def set_subscriptions
      pundit_authorize(Subscription)
      @subscriptions = pundit_scope(Subscription.includes(:plan, :price))
      @subscriptions = attribute_sortable(@subscriptions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::SubscriptionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::SubscriptionPolicy)
    end

    def subscription_params
      params.require(:subscription).permit(:price_id)
    end

    def cancel_params
      params.require(:subscription).permit(:cancel_reason, :cancel_at_period_end)
    end
end
