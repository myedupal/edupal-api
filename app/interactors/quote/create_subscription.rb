class Quote::CreateSubscription
  include Interactor

  def call
    stripe_subscription = Stripe::Subscription.retrieve(context.stripe_quote.subscription)
    context.stripe_subscription = stripe_subscription

    context.subscriptions = []
    context.prices.each do |price|
      subscription = Subscription.new(price_id: nil)
      subscription.assign_attributes(
        price: price,
        plan: price.plan,
        quote: context.quote,
        user: context.current_user,
        created_by: context.current_user,
        stripe_subscription_id: stripe_subscription.id,
        start_at: Time.zone.at(stripe_subscription.start_date),
        status: stripe_subscription.status,
        current_period_start: Time.zone.at(stripe_subscription.current_period_start),
        current_period_end: Time.zone.at(stripe_subscription.current_period_end)
      )
      subscription.save!
      context.subscriptions << subscription
    end

  rescue Stripe::InvalidRequestError => e
    Rails.logger.error(e.message)
    context.fail!(error_message: I18n.t('errors.stripe_quote_error'), stripe_error: e)
  end

end
