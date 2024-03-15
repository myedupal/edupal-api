require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:subscriptions).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:prices).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:plan_type).with_values({ stripe: 'stripe', razorpay: 'razorpay' }).backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'callbacks' do
    describe '#create_stripe_product' do
      it 'creates a stripe product' do
        plan = build(:plan)
        expect do
          plan.save
          plan.reload
        end.to change { plan.stripe_product_id }.from(nil)
      end
    end

    describe '#update_stripe_product' do
      it 'updates a stripe product' do
        plan = create(:plan, name: 'old name')
        plan.update!(name: 'new name')
        stripe_product = Stripe::Product.retrieve(plan.stripe_product_id)
        expect(stripe_product.name).to eq('new name')
      end
    end
  end
end
