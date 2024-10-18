require 'rails_helper'

RSpec.describe SubmissionAnswer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:submission) }
    it { is_expected.to belong_to(:question) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    subject { create(:submission_answer) }

    it { is_expected.to validate_presence_of(:answer) }
    it { is_expected.to validate_presence_of(:recorded_time) }
    it { is_expected.to validate_uniqueness_of(:question_id).scoped_to(:submission_id).case_insensitive }

    context 'when submission is present' do
      let!(:challenge) { create(:challenge) }
      let!(:question) { create(:question, :mcq_with_answer) }
      let!(:challenge_question) { create(:challenge_question, challenge: challenge, question: question) }
      let!(:submission) { create(:submission, challenge: challenge) }
      let!(:submission_answer) { build(:submission_answer, submission: submission, question: question) }
      let!(:other_submission_answer) { build(:submission_answer, submission: submission, skip_challenge_question: true) }

      it { expect(submission_answer).to be_valid }
      it { expect(other_submission_answer).not_to be_valid }
    end
  end

  describe 'methods' do
    describe '#evaluate' do
      let!(:challenge) { create(:challenge) }
      let!(:question) { create(:question, :mcq_with_answer) }
      let!(:expected_score) { 101 }
      let!(:challenge_question) { create(:challenge_question, challenge: challenge, question: question, score: expected_score) }
      let!(:submission) { create(:submission, challenge: challenge) }
      let!(:submission_answer) { create(:submission_answer, submission: submission, question: question, answer: 'X') }
      let(:correct_answer) { question.answers.correct.first!.text }
      let(:incorrect_answer) { create(:answer, question: question, text: 'F', is_correct: false).text }

      context 'when question is mcq' do
        it 'updates is_correct and score' do
          submission_answer.update(answer: correct_answer)
          expect do
            submission_answer.evaluate(force: true)
          end.to change(submission_answer, :evaluated_at)
          expect(submission_answer.is_correct).to be true
          expect(submission_answer.score).to eq(expected_score)

          submission_answer.update(answer: incorrect_answer)
          expect do
            submission_answer.evaluate(force: true)
          end.to change(submission_answer, :evaluated_at)
          expect(submission_answer.is_correct).to be false
          expect(submission_answer.score).to eq(0)
        end
      end

      context 'when question is not mcq' do
        let!(:question) { create(:question, :open_ended) }
        let!(:submission_answer) { create(:submission_answer, submission: submission, question: question, answer: 'X') }

        it 'does not update is_correct and score' do
          expect do
            submission_answer.evaluate(force: true)
          end.not_to change(submission_answer, :evaluated_at)
          expect(submission_answer.is_correct).to be false
          expect(submission_answer.score).to eq(0)
        end
      end

      context 'when evaluated_at is present' do
        let!(:submission_answer) { create(:submission_answer, submission: submission, question: question, answer: correct_answer, evaluated_at: Time.current) }

        it 'does not update evaluated_at' do
          expect do
            submission_answer.evaluate
          end.not_to change(submission_answer, :evaluated_at)
        end

        it 'update evaluated_at when force is true' do
          expect do
            submission_answer.evaluate(force: true)
          end.to change(submission_answer, :evaluated_at)
        end
      end
    end
  end

  describe 'callbacks' do
    describe '#set_user_id' do
      it 'sets user_id to submission user_id' do
        submission = create(:submission)
        submission_answer = build(:submission_answer, submission: submission, user: nil)

        expect do
          submission_answer.valid?
        end.to change(submission_answer, :user_id).from(nil).to(submission.user_id)
      end
    end

    # describe 'before_commit #evaluate' do
    #   context 'when submission is blank' do
    #     let!(:question) { create(:question, :mcq_with_answer) }
    #     let!(:correct_answer) { question.answers.first.text }
    #     let!(:submission_answer) { create(:submission_answer, submission: nil, question: question, answer: correct_answer) }

    #     it { expect(submission_answer.is_correct).to be_truthy }
    #   end
    # end
  end
end
