class Quote::CheckActiveSubscription
  include Interactor

  def call
    context.prices.each do |price|
      active_subscription = context.current_user.active_subscriptions.for_plan(plan: price.plan)

      next if active_subscription.blank?

      context.fail!(error_message: I18n.t('errors.active_plan_subscription_exists'),
                    error_metadata: error_active_plan_exist(price.plan))
    end
  end

  private

    def error_active_plan_exist(plan)
      {
        code: 'active_plan_exists',
        plan_id: plan.id,
        plan_name: plan.name
      }
    end
end
