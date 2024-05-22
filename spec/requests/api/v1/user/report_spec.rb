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
        biology_submission = create(:submission, challenge: biology_daily_challenge, user: user)
        biology_questions.each do |question|
          create(:submission_answer, challenge: biology_daily_challenge, submission: biology_submission, question: question)
        end
        biology_submission.submit!

        physics_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: physics, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        physics_submission = create(:submission, challenge: physics_daily_challenge, user: user)
        physics_questions.each do |question|
          create(:submission_answer, challenge: physics_daily_challenge, submission: physics_submission, question: question)
        end
        physics_submission.submit!

        chemistry_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: chemistry, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        chemistry_submission = create(:submission, challenge: chemistry_daily_challenge, user: user)
        chemistry_questions.each do |question|
          create(:submission_answer, challenge: chemistry_daily_challenge, submission: chemistry_submission, question: question)
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
        current_time = Time.current
        travel_to current_time - Faker::Number.within(range: 1..6).hours
        biology_submission = create(:submission, challenge: nil, user: user)
        biology_questions.each do |question|
          create(:submission_answer, submission: biology_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        biology_submission.submit!

        travel_to current_time - Faker::Number.within(range: 1..6).hours
        physics_submission = create(:submission, challenge: nil, user: user)
        physics_questions.each do |question|
          create(:submission_answer, submission: physics_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        physics_submission.submit!

        travel_to current_time - Faker::Number.within(range: 1..6).hours
        chemistry_submission = create(:submission, challenge: nil, user: user)
        chemistry_questions.each do |question|
          create(:submission_answer, submission: chemistry_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        chemistry_submission.submit!
      end

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/reports/points' do
    get('Points report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      before do
        create(:point_activity, account: user, points: 100, action_type: PointActivity.action_types[:redeem])
        create(:point_activity, account: user, points: 50, action_type: PointActivity.action_types[:daily_challenge])
        create(:point_activity, account: user, points: 10, action_type: PointActivity.action_types[:daily_check_in])
        create(:point_activity, account: user, points: 5, action_type: PointActivity.action_types[:answered_question])
      end

      response(200, 'successful') do
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['total_points']).to eq(165)
          expect(json_response['mcq_points']).to eq(5)
          expect(json_response['daily_challenge_points']).to eq(50)
          expect(json_response['daily_check_in_points']).to eq(10)
        end
      end
    end
  end
end
