class Quote::CancelQuoteOrganizer
  include Interactor::Organizer

  organize [
             Quote::CheckStripeQuote,
             Quote::CancelQuote
           ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
