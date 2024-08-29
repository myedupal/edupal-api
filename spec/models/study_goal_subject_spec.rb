require 'rails_helper'

RSpec.describe StudyGoalSubject, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:study_goal) }
    it { is_expected.to belong_to(:subject) }
  end

  describe 'validations' do
    describe 'curriculum_must_match' do
      let(:study_goal_subject) { build(:study_goal_subject, study_goal: study_goal, subject: subject) }

      context 'when curriculum does not match' do
        let(:study_goal) { create(:study_goal, curriculum: create(:curriculum)) }
        let(:subject) { create(:subject, curriculum: create(:curriculum)) }

        it 'is invalid' do
          expect(study_goal_subject).to be_invalid
          expect(study_goal_subject.errors[:subject]).to include("must match the study goal's curriculum")
        end
      end

      context 'when curriculum match' do
        let(:curriculum) { create(:curriculum) }
        let(:study_goal) { create(:study_goal, curriculum: curriculum) }
        let(:subject) { create(:subject, curriculum: curriculum) }

        it 'is valid' do
          expect(study_goal_subject).to be_valid
        end
      end
    end
  end
end
