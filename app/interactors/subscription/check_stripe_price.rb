class Subscription::CheckStripePrice
  include Interactor

  def call
    price = Price.find_by(id: context.subscription_params[:price_id])
    stripe_price = Stripe::Price.retrieve(price.stripe_price_id)
    if price
      context.price = price
      context.plan = price.plan
      context.stripe_price_id = price.stripe_price_id
      context.stripe_price = stripe_price
    else
      context.fail!(error_message: I18n.t('errors.stripe_price_not_found'))
    end
  rescue Stripe::InvalidRequestError
    context.fail!(error_message: I18n.t('errors.stripe_price_not_found'))
  end
end
