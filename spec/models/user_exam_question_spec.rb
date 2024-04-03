require 'rails_helper'

RSpec.describe UserExamQuestion, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user_exam) }
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    subject { create(:user_exam_question) }

    it { is_expected.to validate_uniqueness_of(:question_id).scoped_to(:user_exam_id).case_insensitive }
  end
end
