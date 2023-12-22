require 'rails_helper'

RSpec.describe StripeProfile, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { build(:stripe_profile) }

    it { is_expected.to validate_uniqueness_of(:customer_id).case_insensitive.allow_nil }
    it { is_expected.to validate_uniqueness_of(:user_id).case_insensitive }
  end
end
