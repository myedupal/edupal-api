require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:stripe_profile).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:subscriptions).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:active_subscription).class_name('Subscription') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
