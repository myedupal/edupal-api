class Subscription::UpdateSubscriptionOrganizer
  include Interactor::Organizer

  organize [
    Subscription::CheckStripeCustomer,
    Subscription::CheckStripePaymentMethod,
    Subscription::CheckStripePrice,
    Subscription::UpdateSubscription
  ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
