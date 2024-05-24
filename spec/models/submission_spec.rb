require 'rails_helper'

RSpec.describe Submission, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:challenge).optional }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:submission_answers).dependent(:destroy) }
    it { is_expected.to have_many(:point_activities).dependent(:destroy) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:submission_answers).allow_destroy(true) }
  end

  describe 'validations' do
    context 'when challenge is not present' do
      subject { build(:submission, challenge: nil) }

      it { is_expected.to validate_presence_of(:title) }
    end
  end

  describe 'scopes' do
    describe '.daily_challenge' do
      it 'returns daily challenge submissions' do
        challenge = create(:challenge, challenge_type: :daily)
        submission = create(:submission, challenge: challenge)
        non_challenge_submission = create(:submission, challenge: nil)

        expect(described_class.daily_challenge).to include(submission)
        expect(described_class.daily_challenge).not_to include(non_challenge_submission)
      end
    end

    describe '.mcq' do
      it 'returns mcq submissions' do
        submission = create(:submission, challenge: nil)
        daily_challenge_submission = create(:submission, challenge: create(:challenge, challenge_type: :daily))

        expect(described_class.mcq).to include(submission)
        expect(described_class.mcq).not_to include(daily_challenge_submission)
      end
    end
  end

  describe 'aasm' do
    describe 'default state' do
      it { is_expected.to have_state(:pending) }
    end

    describe 'guards' do
      describe '#within_challenge_time?' do
        it 'fails if challenge expired' do
          challenge = create(:challenge, challenge_type: :contest, end_at: 1.day.ago)
          submission = create(:submission, challenge: challenge)

          expect(submission).to transition_from(:pending).to(:failed).on_event(:submit)
        end

        it 'fails if challenge not started' do
          challenge = create(:challenge, challenge_type: :contest, start_at: 1.day.from_now)
          submission = create(:submission, challenge: challenge)

          expect(submission).to transition_from(:pending).to(:failed).on_event(:submit)
        end

        it 'submits if challenge within time' do
          challenge = create(:challenge, challenge_type: :contest, start_at: 1.hour.ago, end_at: 1.hour.from_now)
          submission = create(:submission, challenge: challenge)

          expect(submission).to transition_from(:pending).to(:submitted).on_event(:submit)
        end

        it 'return true if challenge is nil' do
          submission = create(:submission, challenge: nil)

          expect(submission.send(:within_challenge_time?)).to be_truthy
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#evaluate_answers' do
      let(:challenge) { create(:challenge, challenge_type: :daily, start_at: Time.current, penalty_seconds: 100) }
      let(:question) { create(:question, :mcq_with_answer) }
      let(:submission) { create(:submission, challenge: challenge) }

      it 'evaluates answers' do
        travel_to Time.zone.parse('2024-03-12 17:30:00') do
          create(:submission_answer, submission: submission, question: question, answer: question.answers.first.text)
          submission.submit!
          submission.reload
          submission.submission_answers.each do |submission_answer|
            expect(submission_answer.evaluated_at).to be_present
          end
        end
      end
    end

    describe '#calculate_score' do
      it 'calculates score' do
        submission = create(:submission, :with_submission_answers, challenge: nil)
        submission.submit!
        submission.reload
        expected_score = Setting.answered_question_points * submission.submission_answers.count
        expect(submission.score).to eq(expected_score)
        expect(submission.total_score).to eq(expected_score)
      end

      it 'calculates total score for challenge' do
        challenge = create(:challenge, :contest, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        submission = create(:submission, :with_incorrect_submission_answers, challenge: challenge)
        submission.submit!
        submission.reload
        expected_score = submission.submission_answers.sum(&:score)
        expected_total_score = challenge.challenge_questions.sum(:score)

        expect(submission.score).to eq(expected_score)
        expect(submission.total_score).to eq(expected_total_score)
      end
    end

    describe '#calculate_completion_seconds' do
      it 'calculates completion seconds' do
        travel_to Time.zone.parse('2024-03-12 17:30:00')
        submission = create(:submission, challenge: nil)

        travel_to Time.zone.parse('2024-03-12 17:30:30')
        submission.submit!

        submission.reload
        expect(submission.completion_seconds).to eq(30)
      end

      it 'calculates completion seconds for daily challenge' do
        travel_to Time.zone.parse('2024-03-12 17:30:00')
        challenge = create(:challenge, challenge_type: :daily, start_at: 1.hour.ago, penalty_seconds: 100)
        submission = create(:submission, :with_submission_answers, challenge: challenge)

        travel_to Time.zone.parse('2024-03-12 17:30:30')
        submission.submit!

        submission.reload
        expect(submission.completion_seconds).to eq(30)
      end

      it 'calculates completion seconds for contest' do
        challenge = create(:challenge, challenge_type: :contest, start_at: 1.hour.ago, penalty_seconds: 100)
        submission = create(:submission, :with_submission_answers, challenge: challenge)
        submission.submit!
        submission.reload

        expect(submission.completion_seconds).to eq(60 * 60)
      end
    end

    describe '#update_user_streaks' do
      it 'updates user daily streak and maximum streak to 1' do
        user = create(:user)
        submission = create(:submission, :with_submission_answers, user: user)

        expect do
          submission.submit!
          user.reload
        end.to change { user.daily_streak }.from(0).to(1)
           .and change { user.maximum_streak }.from(0).to(1)
      end

      it 'update user daily streak to 7' do
        user = create(:user, daily_streak: 6, maximum_streak: 10)
        submission = create(:submission, :with_submission_answers, user: user)

        expect do
          submission.submit!
          user.reload
        end.to change { user.daily_streak }.from(6).to(7)
           .and(not_change { user.maximum_streak })
      end
    end

    describe '#create_or_update_daily_challenge_point_activity' do
      it 'creates point activity for daily challenge if it is full score' do
        submission = create(:submission, :with_submission_answers)
        expect do
          submission.submit!
        end.to change { submission.user.point_activities.count }.by(1)
      end

      it 'does not create point activity for daily challenge if it is not full score' do
        submission = create(:submission, :with_incorrect_submission_answers)
        expect do
          submission.submit!
        end.not_to(change { submission.user.point_activities.count })
      end
    end

    describe '#create_answered_question_point_activity' do
      it 'creates answered_question point_activity' do
        user = create(:user)
        submission = create(:submission, :with_submission_answers, user: user, challenge: nil)

        expect do
          submission.submit!
        end.to change { user.point_activities.count }.by(1)
      end
    end
  end

  describe 'methods' do
    describe '#is_user_first_full_score_daily_challenge_submission?' do
      let(:user) { create(:user) }

      it 'returns true if user has no previous submissions' do
        submission = build(:submission, user: user, score: 100, total_score: 100)
        expect(submission.send(:is_user_first_full_score_daily_challenge_submission?)).to be_truthy
      end

      it 'returns false if user has previous full score submissions' do
        create(:submission, :with_submission_answers, :submitted, user: user)
        submission = create(:submission, :with_submission_answers, user: user)
        expect(submission.send(:is_user_first_full_score_daily_challenge_submission?)).to be_falsey
      end

      it 'returns true if user has previous full score submissions with lower score' do
        create(:submission, :with_incorrect_submission_answers, :submitted, user: user)
        submission = create(:submission, :with_submission_answers, user: user)
        expect(submission.send(:is_user_first_full_score_daily_challenge_submission?)).to be_truthy
      end
    end
  end
end
