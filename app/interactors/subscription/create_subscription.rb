class Subscription::CreateSubscription
  include Interactor

  def call
    case context.plan.plan_type
    when 'stripe'
      create_stripe_subscription
    when 'razorpay'
      create_razorpay_subscription
    else
      context.fail!(error_message: I18n.t('errors.plan_type_not_found'))
    end
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error(e.message)
    context.fail!(error_message: I18n.t('errors.stripe_subscription_create_failed'))
  end

  private

    def create_stripe_subscription
      stripe_subscription = Stripe::Subscription.create(
        customer: context.stripe_customer_id,
        default_payment_method: context.stripe_payment_method_id,
        items: [
          {
            price: context.stripe_price_id
          }
        ],
        metadata: {
          user_id: context.current_user.id,
          environment: Rails.env
        },
        collection_method: 'charge_automatically',
        payment_behavior: 'allow_incomplete'
      )
      context.stripe_subscription = stripe_subscription

      subscription = Subscription.new(context.subscription_params)
      subscription.assign_attributes(
        price: context.price,
        plan: context.plan,
        user: context.current_user,
        created_by: context.current_user,
        stripe_subscription_id: stripe_subscription.id,
        start_at: Time.zone.at(stripe_subscription.start_date),
        status: stripe_subscription.status,
        current_period_start: Time.zone.at(stripe_subscription.current_period_start),
        current_period_end: Time.zone.at(stripe_subscription.current_period_end)
      )
      subscription.save!
      context.subscription = subscription
    end

    def create_razorpay_subscription
      razorpay_subscription = Razorpay::Subscription.create(
        plan_id: context.razorpay_plan_id,
        customer_notify: 1,
        total_count: 1,
        quantity: 1,
        start_at: Time.zone.now.to_i,
        expire_by: 1.hour.from_now.to_i,
        notes: {
          user_id: context.current_user.id
        }
      )
      context.razorpay_subscription = razorpay_subscription
      subscription_start_at = begin
        Time.zone.at(razorpay_subscription.start_at)
      rescue StandardError
        nil
      end
      subscription_current_period_start = begin
        Time.zone.at(razorpay_subscription.current_start)
      rescue StandardError
        nil
      end
      subscription_current_period_end = begin
        Time.zone.at(razorpay_subscription.current_end)
      rescue StandardError
        nil
      end

      subscription = Subscription.new(context.subscription_params)
      subscription.assign_attributes(
        price: context.price,
        plan: context.plan,
        user: context.current_user,
        created_by: context.current_user,
        razorpay_subscription_id: razorpay_subscription.id,
        start_at: subscription_start_at,
        status: razorpay_subscription.status,
        current_period_start: subscription_current_period_start,
        current_period_end: subscription_current_period_end,
        razorpay_short_url: razorpay_subscription.short_url
      )
      subscription.save!
      context.subscription = subscription
    end
end
