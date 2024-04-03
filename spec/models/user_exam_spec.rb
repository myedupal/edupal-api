require 'rails_helper'

RSpec.describe UserExam, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:created_by).class_name('Account') }
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to have_many(:user_exam_questions).dependent(:destroy) }
    it { is_expected.to have_many(:questions).through(:user_exam_questions) }
    it { is_expected.to have_many(:saved_user_exams).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'nanoid' do
    it 'generates a nanoid on create' do
      user_exam = create(:user_exam)
      expect(user_exam.nanoid).to be_present
    end
  end
end
