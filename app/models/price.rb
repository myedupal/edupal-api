class Price < ApplicationRecord
  belongs_to :plan

  # has_many :subscriptions, dependent: :restrict_with_error

  monetize :amount_cents

  enum billing_cycle: { month: 'month', year: 'year' }, _default: 'month'

  validates :billing_cycle, uniqueness: { scope: :plan_id }

  before_save :create_stripe_price

  private

    def create_stripe_price
      stripe_price = Stripe::Price.create(
        product: plan.stripe_product_id,
        unit_amount: amount_cents,
        currency: amount.currency.iso_code.downcase,
        recurring: { interval: billing_cycle }
      )
      self.stripe_price_id = stripe_price.id
    end
end
