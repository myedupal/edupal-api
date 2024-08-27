class Api::V1::User::QuotesController < Api::V1::User::ApplicationController
  before_action :set_quote, only: [:show, :update, :accept, :cancel, :payment_intent, :show_pdf]
  before_action :set_quotes, only: [:index]

  def index
    @pagy, @quotes = pagy(@quotes)
    render json: @quotes
  end

  def show
    render json: @quote
  end

  def create
    pundit_authorize(Quote.new)

    if price_params[:price_ids].count > 1
      # While the Quote interactors is designed with multiple prices in mind
      # the subscription interactor currently does not account for the potential of multiple prices
      # therefore there would be issues if user attempt to edit a subscription consisting of multiple prices
      # due to that, this feature is disabled until subscription interactor is refactored
      render json: ErrorResponse.new("Multiple prices in one quote is currently unsupported"), status: :unprocessable_entity
    end

    organizer = Quote::CreateQuoteOrganizer.call(
      current_user: current_user,
      price_params: price_params,
      promo_code_params: promotion_code_params
    )

    if organizer.success?
      render json: organizer.quote
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error, metadata: error_metadata(organizer)), status: :unprocessable_entity
    end
  end

  def update
    organizer = Quote::UpdateQuoteOrganizer.call(
      current_user: current_user,
      quote: @quote,
      promo_code_params: promotion_code_params
    )

    if organizer.success?
      render json: organizer.quote
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error, metadata: error_metadata(organizer)), status: :unprocessable_entity
    end
  end

  def accept
    organizer = Quote::AcceptQuoteOrganizer.call(
      current_user: current_user,
      quote: @quote
    )

    if organizer.success? && organizer.stripe_invoice&.status == 'paid'
      render json: organizer.quote
    elsif organizer.success? && organizer.stripe_invoice&.status == 'open'
      payment_intent = Stripe::PaymentIntent.retrieve(context.stripe_invoice.payment_intent)
      render json: {
        hosted_invoice_url: organizer.stripe_invoice.hosted_invoice_url,
        payment_intent: payment_intent.id,
        client_secret: payment_intent.client_secret,
        invoice_error: context.stripe_invoice_error.slice(:code, :message, :param, :type)
      }, status: :payment_required
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error, metadata: error_metadata(organizer)), status: :unprocessable_entity
    end
  end

  def payment_intent
    if @quote.status != 'accepted'
      render json: ErrorResponse.new(I18n.t('errors.stripe_quote_not_accepted')), status: :unprocessable_entity
      return
    end
    quote = Stripe::Quote.retrieve(id: @quote.stripe_quote_id, expand: ['invoice'])
    invoice = quote.invoice

    if invoice.status == 'paid'
      render status: :no_content
    else
      payment_intent = Stripe::PaymentIntent.retrieve(invoice.payment_intent)
      render json: {
        hosted_invoice_url: invoice.hosted_invoice_url,
        payment_intent: payment_intent.id,
        client_secret: payment_intent.client_secret
      }, status: :payment_required
    end
  rescue Stripe::StripeError
    render json: ErrorResponse.new(I18n.t('errors.stripe_quote_error')), status: :unprocessable_entity
  end

  def cancel
    organizer = Quote::CancelQuoteOrganizer.call(
      current_user: current_user,
      quote: @quote
    )

    if organizer.success?
      render json: organizer.quote
    else
      error = organizer.error_object || organizer.error_message
      render json: ErrorResponse.new(error, metadata: error_metadata(organizer)), status: :unprocessable_entity
    end
  end

  def show_pdf
    headers.delete("Content-Length")
    headers["Cache-Control"] = "no-cache"
    headers["Content-Type"] = "application/pdf"
    headers["Content-Disposition"] = "attachment; filename=\"quote.pdf\""
    headers["X-Accel-Buffering"] = "no"
    headers["Last-Modified"] = Time.now.httpdate.to_s

    response.status = 200

    self.response_body = Enumerator.new do |enumerator|
      Stripe::Quote.pdf(@quote.stripe_quote_id) do |read_body_chunk|
        enumerator << read_body_chunk
      end
    end
  rescue Stripe::InvalidRequestError
    render json: ErrorResponse.new(I18n.t('errors.stripe_quote_error')), status: :unprocessable_entity
  end

  private

    def error_metadata(organizer)
      if organizer.error_metadata.present?
        organizer.error_metadata
      elsif organizer.stripe_error.present? && organizer.stripe_error&.json_body&.dig(:error).present?
        {
          code: 'stripe_error',
          stripe_error: organizer.stripe_error.json_body[:error].slice(:code, :message, :param, :type)
        }
      elsif organizer.stripe_error.present?
        {
          code: 'stripe_error',
          stripe_error: { message: organizer.stripe_error&.message || "unknown stripe error" }
        }
      end
    end

    def set_quote
      @quote = pundit_scope(Quote).find(params[:id])
      pundit_authorize(@quote) if @quote
    end

    def set_quotes
      pundit_authorize(Quote)
      @quotes = pundit_scope(Quote.includes(:subscriptions))
      @quotes = attribute_sortable(@quotes)
      @quotes = status_scopable(@quotes)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::QuotePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::QuotePolicy)
    end

    def price_params
      params.permit(price_ids: []).tap do |p|
        p.require(:price_ids)
      end
    end

    def promotion_code_params
      params.permit(:promotion_code)
    end
end
