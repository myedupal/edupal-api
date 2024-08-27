class Quote::SetPromotionCode
  include Interactor

  def call
    return unless context.promo_code_params&.dig(:promotion_code).present?

    promo_code = context.promo_code_params[:promotion_code]

    promotion_codes = Stripe::PromotionCode.list(
      active: true,
      code: context.promo_code_params[:promotion_code],
      limit: 1
    )

    promotion_code = promotion_codes.data.first

    if promotion_code.nil?
      context.fail!(error_message: I18n.t('errors.promotion_code_not_found'),
                    error_metadata: error_promotion_code_not_found(promo_code))
    end

    context.stripe_promotion_code = promotion_code
  end

  private

    def error_promotion_code_not_found(promotion_code)
      {
        code: 'promotion_code_not_found',
        promotion_code: promotion_code
      }
    end
end
