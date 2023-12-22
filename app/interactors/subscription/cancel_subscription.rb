class Subscription::CancelSubscription
  include Interactor

  def call
    if context.cancel_params[:cancel_at_period_end].present? && ActiveModel::Type::Boolean.new.cast(context.cancel_params[:cancel_at_period_end])
      cancel_at_period_end
    else
      cancel_now
    end
    context.subscription.assign_attributes(context.cancel_params)
    context.subscription.assign_attributes(
      status: context.stripe_subscription.status,
      canceled_at: Time.current,
      current_period_start: Time.zone.at(context.stripe_subscription.current_period_start),
      current_period_end: Time.zone.at(context.stripe_subscription.current_period_end),
      end_at: context.subscription_end_at
    )
    context.subscription.save!
  rescue Stripe::InvalidRequestError
    context.fail!(error_message: I18n.t('errors.stripe_subscription_cancel_failed'))
  end

  private

    def cancel_at_period_end
      context.stripe_subscription = Stripe::Subscription.update(context.subscription.stripe_subscription_id,
                                                                cancel_at_period_end: true, cancellation_details: { comment: context.cancel_params[:cancel_reason] })
      context.subscription_end_at = Time.zone.at(context.stripe_subscription.current_period_end)
    end

    def cancel_now
      context.stripe_subscription = Stripe::Subscription.delete(context.subscription.stripe_subscription_id,
                                                                cancellation_details: { comment: context.cancel_params[:cancel_reason] })
      context.subscription_end_at = Time.zone.at(context.stripe_subscription.ended_at)
    end
end
