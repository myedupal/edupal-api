class ProcessCallbackJob
  include Sidekiq::Job

  def perform(callback_log_id)
    callback_log = CallbackLog.find(callback_log_id)
    parsed_body = JSON.parse(callback_log.request_body)
    event_type = parsed_body['type']

    case event_type
    when 'customer.subscription.created', 'customer.subscription.updated'
      stripe_subscription_id = parsed_body['data']['object']['id']
      stripe_subscription = Stripe::Subscription.retrieve(stripe_subscription_id)
      subscription = Subscription.find_by!(stripe_subscription_id: stripe_subscription_id)
      subscription.update!(
        status: stripe_subscription.status,
        current_period_start: Time.zone.at(stripe_subscription.current_period_start),
        current_period_end: Time.zone.at(stripe_subscription.current_period_end)
      )
    end
  end
end
