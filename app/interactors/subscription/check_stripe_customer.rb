class Subscription::CheckStripeCustomer
  include Interactor

  def call
    return unless context.plan.stripe?

    context.stripe_profile = context.current_user.stripe_profile
    context.stripe_customer_id = context.stripe_profile&.customer_id

    context.fail!(error_message: I18n.t('errors.stripe_customer_id_missing')) if context.stripe_customer_id.nil?

    begin
      context.stripe_customer = Stripe::Customer.retrieve(context.stripe_customer_id)
    rescue Stripe::InvalidRequestError
      context.fail!(error_message: I18n.t('errors.stripe_customer_id_invalid'))
    end
  end
end
