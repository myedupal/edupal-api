class Subscription::CheckStripePaymentMethod
  include Interactor

  def call
    context.stripe_payment_method_id = context.stripe_profile.payment_method_id

    context.fail!(error_message: I18n.t('errors.stripe_payment_method_id_missing')) if context.stripe_payment_method_id.blank?

    begin
      context.stripe_payment_method = Stripe::PaymentMethod.retrieve(context.stripe_payment_method_id)
    rescue Stripe::InvalidRequestError
      context.fail!(error_message: I18n.t('errors.stripe_payment_method_not_found'))
    end
  end
end
