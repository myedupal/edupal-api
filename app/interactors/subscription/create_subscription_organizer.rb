class Subscription::CreateSubscriptionOrganizer
  include Interactor::Organizer

  organize [
    Subscription::CheckActiveSubscription,
    Subscription::CheckStripeCustomer,
    Subscription::CheckStripePaymentMethod,
    Subscription::CheckStripePrice,
    Subscription::CreateSubscription
  ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
