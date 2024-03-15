class Subscription::CancelSubscription
  include Interactor

  def call
    if context.cancel_params[:cancel_at_period_end].present? && ActiveModel::Type::Boolean.new.cast(context.cancel_params[:cancel_at_period_end])
      cancel_at_period_end
    else
      cancel_now
    end
    update_subscription
  rescue Stripe::InvalidRequestError
    context.fail!(error_message: I18n.t('errors.stripe_subscription_cancel_failed'))
  rescue Razorpay::BadRequestError
    context.fail!(error_message: I18n.t('errors.razorpay_subscription_cancel_failed'))
  end

  private

    def cancel_at_period_end
      case context.subscription.plan.plan_type
      when 'stripe'
        context.stripe_subscription = Stripe::Subscription.update(context.subscription.stripe_subscription_id,
                                                                  cancel_at_period_end: true,
                                                                  cancellation_details: { comment: context.cancel_params[:cancel_reason] })
        context.subscription_end_at = Time.zone.at(context.stripe_subscription.current_period_end)
      when 'razorpay'
        context.razorpay_subscription = Razorpay::Subscription.cancel(context.subscription.razorpay_subscription_id,
                                                                      { cancel_at_cycle_end: 1,
                                                                        notes: { cancel_reason: context.cancel_params[:cancel_reason] } })
        context.subscription_end_at = begin
          Time.zone.at(context.razorpay_subscription.current_end)
        rescue StandardError
          nil
        end
      else
        context.fail!(error_message: I18n.t('errors.plan_type_not_found'))
      end
    end

    def cancel_now
      case context.subscription.plan.plan_type
      when 'stripe'
        context.stripe_subscription = Stripe::Subscription.delete(context.subscription.stripe_subscription_id,
                                                                  cancellation_details: { comment: context.cancel_params[:cancel_reason] })
        context.subscription_end_at = Time.zone.at(context.stripe_subscription.ended_at)
      when 'razorpay'
        context.razorpay_subscription = Razorpay::Subscription.cancel(context.subscription.razorpay_subscription_id,
                                                                      { cancel_at_cycle_end: 0,
                                                                        note: { cancel_reason: context.cancel_params[:cancel_reason] } })
        context.subscription_end_at = begin
          Time.zone.at(context.razorpay_subscription.ended_at)
        rescue StandardError
          nil
        end
      else
        context.fail!(error_message: I18n.t('errors.plan_type_not_found'))
      end
    end

    def update_subscription
      case context.subscription.plan.plan_type
      when 'stripe'
        context.subscription.assign_attributes(context.cancel_params)
        context.subscription.assign_attributes(
          status: context.stripe_subscription.status,
          canceled_at: Time.current,
          current_period_start: Time.zone.at(context.stripe_subscription.current_period_start),
          current_period_end: Time.zone.at(context.stripe_subscription.current_period_end),
          end_at: context.subscription_end_at
        )
        context.subscription.save!
      when 'razorpay'
        subscription_current_start = begin
          Time.zone.at(context.razorpay_subscription.current_start)
        rescue StandardError
          nil
        end
        subscription_current_end = begin
          Time.zone.at(context.razorpay_subscription.current_end)
        rescue StandardError
          nil
        end
        context.subscription.assign_attributes(context.cancel_params)
        context.subscription.assign_attributes(
          status: context.razorpay_subscription.status,
          canceled_at: Time.current,
          current_period_start: subscription_current_start,
          current_period_end: subscription_current_end,
          end_at: context.subscription_end_at
        )
        context.subscription.save!
      else
        context.fail!(error_message: I18n.t('errors.plan_type_not_found'))
      end
    end
end
