class Price < ApplicationRecord
  RAZORPAY_BILLING_CYCLE = { day: 'daily', week: 'weekly', month: 'monthly', year: 'yearly' }.freeze

  belongs_to :plan

  has_many :subscriptions, dependent: :restrict_with_error

  monetize :amount_cents

  enum billing_cycle: { month: 'month', year: 'year' }, _default: 'month'

  validates :billing_cycle, uniqueness: { scope: :plan_id }

  before_save :create_stripe_price, if: -> { plan.stripe? }
  before_save :create_razorpay_plan, if: -> { plan.razorpay? }

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

    def create_razorpay_plan
      razorpay_plan = Razorpay::Plan.create(
        period: RAZORPAY_BILLING_CYCLE[billing_cycle.to_sym],
        interval: 1,
        item: {
          name: "#{plan.name} - #{billing_cycle}",
          amount: amount_cents,
          currency: amount_currency
        },
        notes: {
          plan_id: plan.id
        }
      )
      self.razorpay_plan_id = razorpay_plan.id
    end
end
