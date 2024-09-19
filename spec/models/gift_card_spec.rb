require 'rails_helper'

RSpec.describe GiftCard, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to belong_to(:created_by).class_name('Admin') }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:redemption_limit).is_greater_than(0) }
  end

  describe 'callbacks' do
    describe '#generate_code' do
      it 'generates a code before creating a gift card' do
        gift_card = build(:gift_card)
        expect do
          gift_card.save!
        end.to change(gift_card, :code).from(nil)
      end
    end
  end

  describe 'scopes' do
    describe '.query' do
      it 'returns gift cards matching the keyword' do
        gift_card = create(:gift_card, name: 'Gift Card 1')
        create_list(:gift_card, 2, name: 'Gift Card 5')
        expect(described_class.query('1')).to eq([gift_card])
      end
    end
  end
end
