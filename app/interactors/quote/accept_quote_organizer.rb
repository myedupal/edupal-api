class Quote::AcceptQuoteOrganizer
  include Interactor::Organizer

  organize [
             Quote::CheckStripeQuote,
             Quote::CheckStripeLineItems,
             Quote::CheckStripeCustomer,
             Quote::CheckStripePaymentMethod,
             Quote::AcceptQuote,
             Quote::CreateSubscription,
             Quote::PayInvoice
           ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
