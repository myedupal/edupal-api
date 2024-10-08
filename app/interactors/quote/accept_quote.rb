class Quote::AcceptQuote
  include Interactor

  def call
    context.stripe_quote = Stripe::Quote.finalize_quote(context.quote.stripe_quote_id)
    context.stripe_quote = Stripe::Quote.accept(context.quote.stripe_quote_id, expand: [:discounts])

    context.quote.update(
      status: context.stripe_quote.status
    )

  rescue Stripe::InvalidRequestError => e
    Rails.logger.error(e.message)
    context.fail!(error_message: I18n.t('errors.stripe_quote_error'), stripe_error: e)
  end

end
