class Quote::CheckStripeLineItems
  include Interactor

  def call
    line_items = Stripe::Quote.list_line_items(context.quote.stripe_quote_id)
    prices = []

    line_items.data.each do |line_item|
      stripe_price_id = line_item.price.id
      price = Price.find_by(stripe_price_id: stripe_price_id)

      context.fail!(error_message: I18n.t('errors.price_not_found')) unless price.present?
      context.fail!(error_message: I18n.t('errors.plan_type_not_supported')) unless price.plan.plan_type == 'stripe'

      prices << price
      active_subscription = context.current_user.active_subscriptions.for_plan(plan: price.plan)

      next if active_subscription.blank?

      context.fail!(
        error_message: I18n.t('errors.active_plan_subscription_exists'),
        error_metadata: error_active_plan_exist(price.plan)
      )
    end

    context.stripe_quote_line_items = line_items
    context.prices = prices
  rescue Stripe::InvalidRequestError => e
    context.quote.update(status: :invalid)
    context.fail!(error_message: I18n.t('errors.stripe_quote_not_found'), stripe_error: e)
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
