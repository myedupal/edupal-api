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

    describe '#update_user_streaks' do
      it 'updates user daily streak and maximum streak to 1' do
        user = create(:user)
        submission = create(:challenge_submission, :with_submission_answers, user: user)

        expect do
          submission.submit!
          user.reload
        end.to change { user.daily_streak }.from(0).to(1)
           .and change { user.maximum_streak }.from(0).to(1)
      end

      it 'update user daily streak to 7' do
        user = create(:user, daily_streak: 6, maximum_streak: 10)
        submission = create(:challenge_submission, :with_submission_answers, user: user)

        expect do
          submission.submit!
          user.reload
        end.to change { user.daily_streak }.from(6).to(7)
           .and(not_change { user.maximum_streak })
      end
    end
  end

  describe 'methods' do
    describe '#is_user_first_full_score_daily_challenge_submission?' do
      let(:user) { create(:user) }

      it 'returns true if user has no previous submissions' do
        submission = build(:challenge_submission, user: user, score: 100, total_score: 100)
        expect(submission.send(:is_user_first_full_score_daily_challenge_submission?)).to be_truthy
      end

      it 'returns false if user has previous full score submissions' do
        create(:challenge_submission, :with_submission_answers, :submitted, user: user)
        submission = create(:challenge_submission, :with_submission_answers, user: user)
        expect(submission.send(:is_user_first_full_score_daily_challenge_submission?)).to be_falsey
      end

      it 'returns true if user has previous full score submissions with lower score' do
        create(:challenge_submission, :with_incorrect_submission_answers, :submitted, user: user)
        submission = create(:challenge_submission, :with_submission_answers, user: user)
        expect(submission.send(:is_user_first_full_score_daily_challenge_submission?)).to be_truthy
      end
    end
  end
end
