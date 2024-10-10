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

  def redeem
    @gift_card = GiftCard.find_by(code: redeem_subscription_params[:redeem_code])

    return render json: ErrorResponse.new('Invalid gift card code'), status: :bad_request unless @gift_card

    return render json: ErrorResponse.new('You already have an active subscription for this plan'), status: :bad_request if current_user.active_subscriptions.for_plan(plan: @gift_card.plan).present?

    return render json: ErrorResponse.new('Gift card has already been redeemed'), status: :bad_request unless @gift_card.redeemable?

    return render json: ErrorResponse.new('Gift card has expired'), status: :bad_request if @gift_card.expired?

    return render json: ErrorResponse.new('You cannot redeem the same gift card twice'), status: :bad_request if current_user.subscriptions.exists?(redeem_code: @gift_card.code)

    ActiveRecord::Base.transaction do
      @subscription = Subscription.create!(
        plan: @gift_card.plan,
        status: 'active',
        user: current_user,
        created_by: current_user,
        start_at: Time.zone.now,
        end_at: (@gift_card.duration || 0).days.from_now,
        auto_renew: false,
        redeem_code: @gift_card.code
      )

      @gift_card.redeem!
    end

    render json: @subscription
  rescue ActiveRecord::RecordInvalid => e
    render json: ErrorResponse.new(e.record), status: :unprocessable_entity
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
      @subscriptions = status_scopable(@subscriptions)
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

    def redeem_subscription_params
      params.require(:subscription).permit(:redeem_code)
    end

    def cancel_params
      params.require(:subscription).permit(:cancel_reason, :cancel_at_period_end)
    end
end
