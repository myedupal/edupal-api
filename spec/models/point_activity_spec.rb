require 'rails_helper'

RSpec.describe PointActivity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:activity).optional(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:points).only_integer }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:action_type)
        .with_values({ redeem: 'Redeem',
                       daily_challenge: 'DailyChallenge',
                       daily_check_in: 'DailyCheckIn',
                       answered_question: 'AnsweredQuestion' })
        .backed_by_column_of_type(:string)
    }
  end
end
