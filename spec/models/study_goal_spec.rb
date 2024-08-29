require 'rails_helper'

RSpec.describe StudyGoal, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:curriculum) }
    it { is_expected.to have_many(:study_goal_subjects) }
    it { is_expected.to have_many(:subjects).through(:study_goal_subjects) }
  end

  describe 'accepts_nested_for' do
    it { is_expected.to accept_nested_attributes_for(:study_goal_subjects).allow_destroy(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:a_grade_count) }
    describe 'uniqueness of' do
      subject { build(:study_goal) }
      it { is_expected.to validate_uniqueness_of(:curriculum_id).scoped_to(:user_id).case_insensitive }
    end
  end
end
