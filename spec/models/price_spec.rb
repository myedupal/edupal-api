require 'rails_helper'

RSpec.describe Price, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to have_many(:subscriptions).dependent(:restrict_with_error) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:billing_cycle).with_values(month: 'month', year: 'year').backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    describe 'billing_cycle uniqueness' do
      it 'does not allow duplicate billing_cycle values for the same plan' do
        plan = create(:plan)
        create(:price, plan: plan, billing_cycle: :month)
        new_price = build(:price, plan: plan, billing_cycle: :month)
        expect(new_price).not_to be_valid
      end
    end
  end

  describe 'callbacks' do
    context 'when plan is stripe' do
      let(:plan) { create(:plan, plan_type: :stripe) }

      describe '#create_stripe_price' do
        it 'creates a stripe price' do
          price = build(:price, plan: plan)
          expect do
            price.save
            price.reload
          end.to change { price.stripe_price_id }.from(nil)
        end

        it 'create a stripe price during update' do
          price = create(:price, plan: plan, amount_cents: 1000)
          price.update!(amount_cents: 2000)
          price.reload
          stripe_price = Stripe::Price.retrieve(price.stripe_price_id)
          expect(stripe_price.unit_amount).to eq(2000)
        end
      end
    end

    context 'when plan is razorpay' do
      let(:plan) { create(:plan, plan_type: :razorpay) }

      describe '#create_razorpay_plan' do
        it 'creates a razorpay plan' do
          price = build(:price, plan: plan)
          expect do
            price.save
            price.reload
          end.to change { price.razorpay_plan_id }.from(nil)
        end

        it 'create a razorpay plan during update' do
          price = create(:price, plan: plan, amount_cents: 1000)
          expect do
            price.update!(amount_cents: 2000)
            price.reload
          end.to(change { price.razorpay_plan_id })
        end
      end
    end
  end
end
