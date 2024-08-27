class Quote::CreateQuoteOrganizer
  include Interactor::Organizer

  organize [
             Quote::SetPriceAndPlan,
             Quote::CheckActiveSubscription,
             Quote::SetPromotionCode,
             Quote::CheckStripeCustomer,
             Quote::CheckStripePaymentMethod,
             Quote::CreateQuote
           ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
