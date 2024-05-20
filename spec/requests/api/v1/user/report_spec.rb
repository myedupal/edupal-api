require 'swagger_helper'

RSpec.describe 'api/v1/user/reports', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:curriculum) { create(:curriculum, name: 'IGCSE') }
  let(:biology) { create(:subject, name: 'Biology', curriculum: curriculum) }
  let(:physics) { create(:subject, name: 'Physics', curriculum: curriculum) }
  let(:chemistry) { create(:subject, name: 'Chemistry', curriculum: curriculum) }
  let!(:biology_questions) { create_list(:question, 10, :mcq_with_answer, subject: biology) }
  let!(:physics_questions) { create_list(:question, 10, :mcq_with_answer, subject: physics) }
  let!(:chemistry_questions) { create_list(:question, 10, :mcq_with_answer, subject: chemistry) }

  path '/api/v1/user/reports/daily_challenge' do
    get('daily challenge report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      before do
        biology_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: biology, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        biology_submission = create(:challenge_submission, challenge: biology_daily_challenge, user: user)
        biology_questions.each do |question|
          create(:submission_answer, challenge: biology_daily_challenge, challenge_submission: biology_submission, question: question)
        end
        biology_submission.submit!

        physics_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: physics, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        physics_submission = create(:challenge_submission, challenge: physics_daily_challenge, user: user)
        physics_questions.each do |question|
          create(:submission_answer, challenge: physics_daily_challenge, challenge_submission: physics_submission, question: question)
        end
        physics_submission.submit!

        chemistry_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: chemistry, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        chemistry_submission = create(:challenge_submission, challenge: chemistry_daily_challenge, user: user)
        chemistry_questions.each do |question|
          create(:submission_answer, challenge: chemistry_daily_challenge, challenge_submission: chemistry_submission, question: question)
        end
        chemistry_submission.submit!
      end

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/reports/mcq' do
    get('MCQ report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      before do
        biology_questions.each do |question|
          create(:submission_answer, challenge_submission: nil, question: question, user: user)
        end

        physics_questions.each do |question|
          create(:submission_answer, challenge_submission: nil, question: question, user: user)
        end

        chemistry_questions.each do |question|
          create(:submission_answer, challenge_submission: nil, question: question, user: user)
        end
      end

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
