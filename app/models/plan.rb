class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error
  has_many :prices, dependent: :destroy

  enum plan_type: { stripe: 'stripe', razorpay: 'razorpay' }, _default: :stripe

  accepts_nested_attributes_for :prices, allow_destroy: true

  validates :name, presence: true

  before_create :create_stripe_product, if: -> { stripe? }
  after_update :update_stripe_product, if: -> { stripe? }

  private

    def create_stripe_product
      stripe_product = Stripe::Product.create(name: name)
      self.stripe_product_id = stripe_product.id
    end

    def update_stripe_product
      Stripe::Product.update(stripe_product_id, name: name)
    end
end
