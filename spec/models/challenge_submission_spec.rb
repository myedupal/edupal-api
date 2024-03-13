require 'rails_helper'

RSpec.describe ChallengeSubmission, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:challenge) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:submission_answers).dependent(:nullify) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:submission_answers).allow_destroy(true) }
  end

  describe 'aasm' do
    describe 'default state' do
      it { is_expected.to have_state(:pending) }
    end

    describe 'guards' do
      describe '#within_challenge_time?' do
        it 'fails if challenge expired' do
          challenge = create(:challenge, challenge_type: :contest, end_at: 1.day.ago)
          submission = create(:challenge_submission, challenge: challenge)

          expect(submission).to transition_from(:pending).to(:failed).on_event(:submit)
        end

        it 'fails if challenge not started' do
          challenge = create(:challenge, challenge_type: :contest, start_at: 1.day.from_now)
          submission = create(:challenge_submission, challenge: challenge)

          expect(submission).to transition_from(:pending).to(:failed).on_event(:submit)
        end

        it 'submits if challenge within time' do
          challenge = create(:challenge, challenge_type: :contest, start_at: 1.hour.ago, end_at: 1.hour.from_now)
          submission = create(:challenge_submission, challenge: challenge)

          expect(submission).to transition_from(:pending).to(:submitted).on_event(:submit)
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#evaluate_answers' do
      let(:challenge) { create(:challenge, challenge_type: :daily, start_at: Time.current, penalty_seconds: 100) }
      let(:question) { create(:question, :mcq_with_answer) }
      let(:expected_score) { 10 }
      let(:challenge_question) { create(:challenge_question, challenge: challenge, question: question, score: expected_score) }
      let(:submission) { create(:challenge_submission, challenge: challenge) }

      before do
        travel_to Time.zone.parse('2024-03-12 17:00:00') do
          challenge_question
        end
      end

      it 'evaluates answers' do
        travel_to Time.zone.parse('2024-03-12 17:30:00') do
          create(:submission_answer, challenge_submission: submission, question: question, answer: question.answers.first.text)
          submission.submit!
          submission.reload
          expect(submission.score).to eq(expected_score)
          expect(submission.total_score).to eq(expected_score)
          expect(submission.penalty_seconds).to eq(0)
          expect(submission.completion_seconds).to eq(63_000)
        end
      end

      it 'evaluates answers with penalty' do
        travel_to Time.zone.parse('2024-03-12 17:15:00') do
          previous_submission = create(:challenge_submission, challenge: challenge, user: submission.user)
          previous_submission.submit!
        end

        travel_to Time.zone.parse('2024-03-12 17:30:00') do
          create(:submission_answer, challenge_submission: submission, question: question, answer: question.answers.first.text)
          submission.submit!
          submission.reload
          expect(submission.score).to eq(expected_score)
          expect(submission.total_score).to eq(expected_score)
          expect(submission.penalty_seconds).to eq(100)
          expect(submission.completion_seconds).to eq(63_100)
        end
      end
    end
  end
end
