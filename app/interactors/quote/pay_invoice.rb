class Quote::PayInvoice
  include Interactor

  def call
    invoice = Stripe::Invoice.retrieve(context.stripe_quote.invoice)
    Stripe::Subscription.update(context.stripe_quote.subscription, default_payment_method: context.stripe_payment_method_id)

    context.stripe_invoice = Stripe::Invoice.finalize_invoice(invoice.id, auto_advance: false)

    context.stripe_invoice = Stripe::Invoice.pay(invoice.id)
  rescue Stripe::StripeError => e
    # capture all stripe errors and store in context
    # do not fail context here, because everything would be rolled back
    # and we want to handle the payment error in the controller instead
    context.stripe_error = e
    context.stripe_invoice_error = e
  end
end
