class Quote::UpdateQuote
  include Interactor

  def call
    discounts = nil
    if context.promo_code_params.key?(:promotion_code) && context.promo_code_params&.dig(:promotion_code).blank?
      discounts = []
    elsif context.stripe_promotion_code.present?
      discounts = [{ promotion_code: context.stripe_promotion_code.id }]
    end

    stripe_quote = Stripe::Quote.update(
      context.quote.stripe_quote_id,
      discounts: discounts,
      expires_at: (Time.now + 1.day).to_i,
      expand: [:discounts]
    )

    context.stripe_quote = stripe_quote

    context.quote.update(
      status: stripe_quote.status,
      quote_expire_at: stripe_quote.expires_at
    )
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error(e.message)
    context.fail!(error_message: I18n.t('errors.stripe_quote_create_failed'), stripe_error: e)
  end
end
