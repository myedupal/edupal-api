require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to belong_to(:exam).optional }
    it { is_expected.to have_many(:activity_questions).dependent(:destroy) }
    it { is_expected.to have_many(:activity_topics).dependent(:destroy) }
    it { is_expected.to have_many(:topics).through(:activity_topics) }
    it { is_expected.to have_many(:activity_papers).dependent(:destroy) }
    it { is_expected.to have_many(:papers).through(:activity_papers) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:activity_type).with_values({ yearly: 'yearly', topical: 'topical' }).backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    context 'when yearly' do
      subject { build(:activity, :yearly) }

      it { is_expected.to validate_presence_of(:exam_id) }
    end

    context 'when topical' do
      subject { create(:activity, :topical) }

      it { is_expected.to validate_absence_of(:exam_id) }
    end
  end

  describe 'callbacks' do
    describe '#set_subject_id' do
      context 'when yearly' do
        let(:exam) { create(:exam) }
        let(:activity) { build(:activity, :yearly, exam: exam) }

        it 'sets the subject_id to the exam paper subject_id' do
          activity.save
          expect(activity.subject_id).to eq(exam.paper.subject_id)
        end
      end
    end
  end

  describe 'methods' do
    describe '#questions_count' do
      let(:subject) { create(:subject) }

      context 'when paper_ids is not empty' do
        let(:paper) { create(:paper, subject: subject) }
        let(:paper2) { create(:paper, subject: subject) }
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(topic_ids: [], paper_ids: [paper.id])
          activity.reload
          create_list(:question, 3, subject: subject, paper: paper)
          create_list(:question, 2, subject: subject, paper: paper2)
        end

        it 'returns the count of questions for the paper_ids' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when topic_ids is not empty' do
        let(:topic) { create(:topic, subject: subject) }
        let(:topic2) { create(:topic, subject: subject) }
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(topic_ids: [topic.id], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, topic_ids: [topic.id])
          create_list(:question, 2, subject: subject, topic_ids: [topic2.id])
        end

        it 'returns the count of questions for the topic_ids' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when years is not empty' do
        let(:exam) { create(:exam, subject: subject, year: 2020) }
        let(:exam2) { create(:exam, subject: subject, year: 2021) }
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(years: [2020], topic_ids: [], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, exam: exam)
          create_list(:question, 2, subject: subject, exam: exam2)
        end

        it 'returns the count of questions for the years' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when seasons is not empty' do
        let(:exam) { create(:exam, subject: subject, season: 'Summer') }
        let(:exam2) { create(:exam, subject: subject, season: 'Winter') }
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(seasons: ['Summer'], topic_ids: [], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, exam: exam)
          create_list(:question, 2, subject: subject, exam: exam2)
        end

        it 'returns the count of questions for the seasons' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when zones is not empty' do
        let(:exam) { create(:exam, subject: subject, zone: 1) }
        let(:exam2) { create(:exam, subject: subject, zone: 2) }
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(zones: [1], topic_ids: [], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, exam: exam)
          create_list(:question, 2, subject: subject, exam: exam2)
        end

        it 'returns the count of questions for the zones' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when levels is not empty' do
        let(:exam) { create(:exam, subject: subject, level: 'O') }
        let(:exam2) { create(:exam, subject: subject, level: 'A') }
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(levels: ['O'], topic_ids: [], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, exam: exam)
          create_list(:question, 2, subject: subject, exam: exam2)
        end

        it 'returns the count of questions for the levels' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when question_type is not empty' do
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(question_type: 'mcq', topic_ids: [], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, question_type: 'mcq')
          create_list(:question, 2, subject: subject, question_type: 'text')
        end

        it 'returns the count of questions for the question_type' do
          expect(activity.questions_count).to eq(3)
        end
      end

      context 'when numbers is not empty' do
        let(:activity) { create(:activity, :topical, subject: subject) }

        before do
          activity.update(numbers: [1], topic_ids: [], paper_ids: [])
          activity.reload
          create_list(:question, 3, subject: subject, number: 1)
          create_list(:question, 2, subject: subject, number: 2)
        end

        it 'returns the count of questions for the numbers' do
          expect(activity.questions_count).to eq(3)
        end
      end
    end
  end
end
