class Subscription::SetPriceAndPlan
  include Interactor

  def call
    price = Price.find(context.subscription_params[:price_id])
    context.price = price
    context.plan = price.plan
    case context.plan.plan_type
    when 'stripe'
      set_stripe_price
    when 'razorpay'
      set_razorpay_plan
    else
      context.fail!(error_message: I18n.t('errors.plan_type_not_found'))
    end
  rescue ActiveRecord::RecordNotFound
    context.fail!(error_message: I18n.t('errors.price_not_found'))
  end

  private

    def set_stripe_price
      context.stripe_price_id = context.price.stripe_price_id
      context.stripe_price = Stripe::Price.retrieve(context.price.stripe_price_id)
    rescue Stripe::InvalidRequestError
      context.fail!(error_message: I18n.t('errors.stripe_price_not_found'))
    end

    def set_razorpay_plan
      context.razorpay_plan_id = context.price.razorpay_plan_id
      context.razorpay_plan = Razorpay::Plan.fetch(context.price.razorpay_plan_id)
    rescue Razorpay::BadRequestError
      context.fail!(error_message: I18n.t('errors.razorpay_plan_not_found'))
    end
end
