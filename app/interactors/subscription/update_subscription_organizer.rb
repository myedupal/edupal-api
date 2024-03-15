class Subscription::UpdateSubscriptionOrganizer
  include Interactor::Organizer

  organize [
    Subscription::SetPriceAndPlan,
    Subscription::CheckStripeCustomer,
    Subscription::CheckStripePaymentMethod,
    Subscription::UpdateSubscription
  ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
