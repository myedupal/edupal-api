class Subscription::UpdateSubscription
  include Interactor

  def call
    stripe_subscription = Stripe::Subscription.retrieve(context.subscription.stripe_subscription_id)
    existing_item_id = stripe_subscription.items.data.first.id
    updated_subscription = Stripe::Subscription.update(context.subscription.stripe_subscription_id,
                                                       {
                                                         payment_behavior: 'pending_if_incomplete',
                                                         default_payment_method: context.stripe_payment_method_id,
                                                         items: [{ id: existing_item_id, price: context.stripe_price_id }]
                                                       })
    context.subscription.update!(
      price: context.price,
      plan: context.plan,
      status: updated_subscription.status,
      current_period_start: Time.zone.at(updated_subscription.current_period_start),
      current_period_end: Time.zone.at(updated_subscription.current_period_end)
    )
    context.stripe_subscription = updated_subscription
  rescue Stripe::InvalidRequestError
    context.fail!(error_message: I18n.t('errors.stripe_subscription_update_failed'))
  end
end
