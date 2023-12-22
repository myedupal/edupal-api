class Subscription::CreateSubscription
  include Interactor

  def call
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
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error(e.message)
    context.fail!(error_message: I18n.t('errors.stripe_subscription_create_failed'))
  end
end
