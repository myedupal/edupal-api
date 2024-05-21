require 'rails_helper'

RSpec.describe DailyCheckIn, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:point_activities).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:daily_check_in) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date).scoped_to(:user_id) }
  end
end
