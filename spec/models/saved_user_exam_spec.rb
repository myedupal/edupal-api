require 'rails_helper'

RSpec.describe SavedUserExam, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:user_exam) }
  end

  describe 'validations' do
    subject { create(:saved_user_exam) }

    it { is_expected.to validate_uniqueness_of(:user_exam_id).scoped_to(:user_id).case_insensitive }
  end
end
