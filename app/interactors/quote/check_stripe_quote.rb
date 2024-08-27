class Quote::CheckStripeQuote
  include Interactor

  def call
    context.stripe_quote = Stripe::Quote.retrieve(context.quote.stripe_quote_id)

    if context.stripe_quote.status == 'canceled'
      context.fail!(error_message: I18n.t('errors.stripe_quote_cancelled'))
    elsif context.stripe_quote.status == 'accepted'
      context.fail!(error_message: I18n.t('errors.stripe_quote_accepted'))
    end
  rescue Stripe::InvalidRequestError => e
    context.quote.update(status: :invalid)
    context.fail!(error_message: I18n.t('errors.stripe_quote_not_found'), stripe_error: e)
  end

end
