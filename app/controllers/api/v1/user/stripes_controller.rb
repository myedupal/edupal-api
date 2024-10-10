class Api::V1::User::StripesController < Api::V1::User::ApplicationController
  before_action :find_or_create_stripe_profile

  def payment_methods
    @payment_methods = Stripe::PaymentMethod.list(
      customer: @stripe_customer.id,
      type: 'card'
    )
    @data = @payment_methods.data&.map do |pm|
      {
        id: pm.id,
        brand: pm.card.brand,
        last4: pm.card.last4,
        exp_month: pm.card.exp_month,
        exp_year: pm.card.exp_year,
        created_at: pm.respond_to?(:created) ? Time.zone.at(pm.created).to_datetime : nil
      }
    end
    render json: { payment_methods: @data }, status: :ok
  end

  def detach_payment_method
    payment_method_id = payment_method_params[:payment_method_id]

    begin
      subscriptions = Stripe::Subscription.list({ customer: @stripe_profile.customer_id, status: :active }).data
    rescue Stripe::InvalidRequestError
      render json: ErrorResponse.new("Something went wrong when retrieving your subscriptions."), status: :bad_request
      return
    end

    in_use_subscriptions = subscriptions.select do |subscription|
      subscription.default_payment_method == payment_method_id
    end
    if in_use_subscriptions.any?
      render json: ErrorResponse.new(
        "You cannot remove a payment method from an active subscription.",
        metadata: { code: 'payment_method_is_use', subscription_ids: in_use_subscriptions.map(&:id) }
      ), status: :bad_request
      return
    end

    begin
      Stripe::PaymentMethod.detach(payment_method_id)
    rescue Stripe::InvalidRequestError
      render json: ErrorResponse.new("Something went wrong when removing the payment method."), status: :bad_request
      return
    end

    @stripe_profile.update(payment_method_id: nil) if @stripe_profile.payment_method_id == payment_method_id

    head :no_content
  end

  def setup_intent
    if @stripe_profile.current_setup_intent_id.present?
      @setup_intent = Stripe::SetupIntent.retrieve(@stripe_profile.current_setup_intent_id)

      # create a new setup intent if the current one is not valid
      unless @setup_intent.status == 'requires_payment_method'
        @setup_intent = Stripe::SetupIntent.create(
          customer: @stripe_customer.id,
          payment_method_types: ['card'],
          usage: 'off_session'
        )
        @stripe_profile.update(current_setup_intent_id: @setup_intent.id)
      end
    else
      @setup_intent = Stripe::SetupIntent.create(
        customer: @stripe_customer.id,
        payment_method_types: ['card'],
        usage: 'off_session'
      )
      @stripe_profile.update(current_setup_intent_id: @setup_intent.id)
    end

    render json: @setup_intent.as_json(only: [:id, :client_secret]), status: :ok
  end

  def default_payment_method
    payment_method_id = payment_method_params[:payment_method_id]
    begin
      Stripe::PaymentMethod.retrieve(payment_method_id)
    rescue Stripe::InvalidRequestError
      render json: ErrorResponse.new("Something went wrong when retrieving the payment method."), status: :bad_request
      return
    end

    begin
      Stripe::PaymentMethod.attach(payment_method_id, customer: @stripe_customer.id)
      Stripe::Customer.update(@stripe_customer.id, invoice_settings: { default_payment_method: payment_method_id })
    rescue Stripe::InvalidRequestError
      render json: ErrorResponse.new("Something went wrong when updating the payment method"), status: :bad_request
      return
    end

    if @stripe_profile.update(payment_method_params)
      render json: @stripe_profile, adapter: :json
    else
      render json: ErrorResponse.new(@stripe_profile)
    end
  end

  def customer
    render json: @stripe_customer, adapter: :json
  end

  private

    def find_or_create_stripe_profile
      @stripe_profile = StripeProfile.find_or_initialize_by(user_id: current_user.id)
      if @stripe_profile.customer_id.present?
        @stripe_customer = Stripe::Customer.retrieve(@stripe_profile.customer_id)
      else
        @stripe_customer = Stripe::Customer.create(
          email: current_user.email,
          name: current_user.name,
          metadata: {
            user_id: current_user.id,
            environment: Rails.env
          }
        )
        @stripe_profile.customer_id = @stripe_customer['id']
        @stripe_profile.save!
      end
    end

    def payment_method_params
      params.require(:stripe).permit(:payment_method_id)
    end
end
