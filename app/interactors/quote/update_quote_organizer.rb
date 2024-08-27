class Quote::UpdateQuoteOrganizer
  include Interactor::Organizer

  organize [
             Quote::SetPromotionCode,
             Quote::UpdateQuote
           ]

  around do |interactor|
    ActiveRecord::Base.transaction do
      interactor.call
    end
  end
end
