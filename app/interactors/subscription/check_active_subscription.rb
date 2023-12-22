class Subscription::CheckActiveSubscription
  include Interactor

  def call
    context.active_subscription = context.current_user.active_subscription
    return if context.active_subscription.blank?

    context.fail!(error_message: I18n.t('errors.active_subscription_exists'))
  end
end
