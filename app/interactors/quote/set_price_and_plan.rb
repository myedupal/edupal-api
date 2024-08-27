class Quote::SetPriceAndPlan
  include Interactor

  def call

    begin
      prices = context.price_params[:price_ids].map do |price_id|
        price = Price.find(price_id)
        context.fail!(error_message: I18n.t('errors.plan_type_not_supported')) if price.plan.plan_type != 'stripe'

        price
      end
      context.prices = prices
    rescue ActiveRecord::RecordNotFound => e
      context.fail!(error_message: I18n.t('errors.price_not_found'),
                    error_metadata: error_price_not_found(e.id))
    end

    begin
      context.stripe_prices = context.prices.map do |price|
        Stripe::Price.retrieve(price.stripe_price_id)
      end
    rescue Stripe::InvalidRequestError => e
      context.fail!(error_message: I18n.t('errors.stripe_price_not_found'), stripe_error: e)
    end
  end

  private

    def error_price_not_found(price_id)
      {
        code: 'price_not_found',
        price_id: price_id
      }
    end
end
