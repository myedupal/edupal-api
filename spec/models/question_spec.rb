require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to belong_to(:exam).optional }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
    it { is_expected.to have_many(:question_images).dependent(:destroy) }
    it { is_expected.to have_many(:question_topics).dependent(:destroy) }
    it { is_expected.to have_many(:topics).through(:question_topics) }
    it { is_expected.to have_many(:submission_answers).dependent(:destroy) }
    it { is_expected.to have_many(:challenge_questions).dependent(:destroy) }
    it { is_expected.to have_many(:activity_questions).dependent(:destroy) }
    it { is_expected.to have_many(:user_exam_questions).dependent(:destroy) }
    it { is_expected.to have_many(:point_activities).dependent(:destroy) }
    it { is_expected.to have_many(:user_collection_questions).dependent(:destroy) }
    it { is_expected.to have_many(:user_collections).through(:user_collection_questions) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:answers) }
    it { is_expected.to accept_nested_attributes_for(:question_images) }
    it { is_expected.to accept_nested_attributes_for(:question_topics) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:question_type).with_values({ mcq: 'mcq', text: 'text' }).backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:number) }

    describe 'uniqueness' do
      subject { create(:question) }

      it { is_expected.to validate_uniqueness_of(:number).case_insensitive.scoped_to(:exam_id) }
    end
  end

  describe 'scopes' do
    describe '.with_activity_presence' do
      let!(:activity) { create(:activity, :topical) }
      let!(:question) { create(:question) }
      let(:another_activity) { create(:activity, :topical) }

      it 'returns true' do
        create(:activity_question, question: question, activity: activity)
        expect(described_class.with_activity_presence(activity.id).first.activity_presence).to be_truthy
      end

      it 'returns false' do
        expect(described_class.with_activity_presence(another_activity.id).first.activity_presence).to be_falsey
      end
    end
  end

  describe 'callbacks' do
    describe '#set_subject_id' do
      let(:subject) { create(:subject) }
      let(:paper) { create(:paper, subject: subject) }
      let(:exam) { create(:exam, paper: paper) }
      let(:question) { build(:question, subject: nil, exam: nil) }

      it 'sets the subject_id from the exam paper' do
        question.exam = exam
        question.valid?
        expect(question.subject_id).to eq(subject.id)
      end
    end
  end
end
