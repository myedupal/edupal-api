class Api::V1::Razorpay::WebhooksController < Api::V1::Razorpay::ApplicationController
  def create
    unless Razorpay::Utility.verify_webhook_signature(request.body.read,
                                                      request.headers['X-Razorpay-Signature'],
                                                      ENV.fetch('RAZORPAY_WEBHOOK_SECRET', 'supersecret'))
      return render json: { message: 'Invalid signature' }, status: :unauthorized
    end
    return head :ok unless params[:event].start_with?('subscription')

    razorpay_subscription_id = params[:payload][:subscription][:entity][:id]
    subscription = Subscription.find_by(razorpay_subscription_id: razorpay_subscription_id)
    return head :ok unless subscription

    razorpay_subscription = Razorpay::Subscription.fetch(razorpay_subscription_id)
    start_at = begin
      Time.zone.at(razorpay_subscription.start_at)
    rescue StandardError
      nil
    end
    end_at = begin
      Time.zone.at(razorpay_subscription.end_at)
    rescue StandardError
      nil
    end
    current_start = begin
      Time.zone.at(razorpay_subscription.current_start)
    rescue StandardError
      nil
    end
    current_end = begin
      Time.zone.at(razorpay_subscription.current_end)
    rescue StandardError
      nil
    end
    subscription.update!(
      status: razorpay_subscription.status,
      start_at: start_at,
      end_at: end_at,
      current_period_start: current_start,
      current_period_end: current_end,
      razorpay_short_url: razorpay_subscription.short_url
    )

    head :ok
  end
end
