class Subscription::CheckActiveSubscription
  include Interactor

  def call
    price = Price.find(context.subscription_params[:price_id])
    context.price = price
    context.plan = price.plan

    active_subscription = context.current_user.active_subscriptions.for_plan(plan: price.plan)

    context.active_subscription = active_subscription
    return if context.active_subscription.blank?

    context.fail!(error_message: I18n.t('errors.active_plan_subscription_exists'))
  rescue ActiveRecord::RecordNotFound
    context.fail!(error_message: I18n.t('errors.price_not_found'))
  end
end
