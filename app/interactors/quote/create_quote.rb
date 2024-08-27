class Quote::CreateQuote
  include Interactor

  def call
    discounts = nil

    discounts = [{ promotion_code: context.stripe_promotion_code.id }] if context.stripe_promotion_code.present?

    line_items = context.stripe_prices.map do |stripe_price|
      { price: stripe_price.id }
    end

    stripe_quote = Stripe::Quote.create(
      customer: context.stripe_customer_id,
      line_items: line_items,
      discounts: discounts,
      metadata: {
        user_id: context.current_user.id,
        environment: Rails.env
      },
      collection_method: 'charge_automatically',
      expires_at: (Time.now + 1.day).to_i
    )

    quote = Quote.new(
      user: context.current_user,
      created_by: context.current_user,
      stripe_quote_id: stripe_quote.id,
      status: stripe_quote.status,
      quote_expire_at: stripe_quote.expires_at
    )
    quote.save!
    context.quote = quote
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error(e.message)
    context.fail!(error_message: I18n.t('errors.stripe_quote_create_failed'), stripe_error: e)
  end
end
