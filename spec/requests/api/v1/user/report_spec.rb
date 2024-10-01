require 'swagger_helper'

RSpec.describe 'api/v1/user/reports', type: :request do
  # change the create(:user) to respective user model name
  let(:curriculum) { create(:curriculum, name: 'IGCSE') }
  let(:user) { create(:user, selected_curriculum: curriculum) }
  let(:Authorization) { bearer_token_for(user) }
  let(:biology) { create(:subject, name: 'Biology', curriculum: curriculum) }
  let(:physics) { create(:subject, name: 'Physics', curriculum: curriculum) }
  let(:chemistry) { create(:subject, name: 'Chemistry', curriculum: curriculum) }

  path '/api/v1/user/reports/daily_challenge' do
    get('daily challenge report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: "filter start date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "filter end date"

      let!(:biology_questions) { create_list(:question, 3, :mcq_with_answer, subject: biology) }
      let!(:physics_questions) { create_list(:question, 3, :mcq_with_answer, subject: physics) }
      let!(:chemistry_questions) { create_list(:question, 3, :mcq_with_answer, subject: chemistry) }

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

  path '/api/v1/user/reports/submission_heatmap' do
    get('submission heatmap') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: "filter start date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "filter end date"
      parameter name: :subject_id, in: :query, type: :string, required: false, description: "filter by subject id"
      parameter name: :challenge_type, in: :query, type: :string, required: false, description: "filter by challenge type"
      parameter name: :mcq_type, in: :query, type: :string, required: false, description: "filter by mcq type or 'all' for any mcq type"

      before do
        biology_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: biology, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        create(:submission, challenge: biology_daily_challenge, user: user, status: :submitted, submitted_at: Time.current.beginning_of_day, created_at: Time.current.beginning_of_day)

        4.times do |i|
          day = i.days.ago.beginning_of_day
          physics_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: physics, start_at: day, end_at: 1.hour.from_now)
          create(:submission, challenge: physics_daily_challenge, user: user, status: :submitted, submitted_at: day + 5.minutes, created_at: day)
        end

        3.times do |i|
          day = i.days.ago.beginning_of_day
          chemistry_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: chemistry, start_at: day, end_at: 1.hour.from_now)
          create(:submission, challenge: chemistry_daily_challenge, user: user, status: :submitted, submitted_at: day + 5.minutes, created_at: day)
        end

        2.times do |i|
          day = (10 + (i * 5)).days.ago.beginning_of_day
          chemistry_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: chemistry, start_at: day, end_at: 1.hour.from_now)
          create(:submission, challenge: chemistry_daily_challenge, user: user, status: :submitted, submitted_at: day + 5.minutes, created_at: day)
        end
      end

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['heatmap'].count).to eq(6)
          expect(data['active_days']).to eq(6)
          expect(data['total_submissions']).to eq(10)
        end
      end
    end
  end


  path '/api/v1/user/reports/daily_challenge_breakdown' do
    get('daily challenge breakdown') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: "filter start date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "filter end date"
      parameter name: :breakdown_for, in: :query, type: :string, required: true, description: "Select data point to group by\nbreakdown for option: subject, month, month_subject"

      let(:physics_questions) { create_list(:question, 2, :mcq_with_answer, subject: physics) }

      before do
        biology_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: biology, start_at: 1.hour.ago, end_at: 1.hour.from_now)
        biology_submission = create(:submission, challenge: biology_daily_challenge, user: user, status: :submitted, submitted_at: Time.current.beginning_of_day, created_at: Time.current.beginning_of_day)
        biology_submission.update_columns(score: 30, total_score: 100)

        3.times do |i|
          day = i.days.ago.beginning_of_day
          physics_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: physics, start_at: day, end_at: 1.hour.from_now)
          submission = create(:submission, challenge: physics_daily_challenge, user: user, status: :pending, submitted_at: day + 5.minutes, created_at: day)
          physics_questions.each.with_index do |question, _|
            if i < 2
              create(:submission_answer, :correct_answer, submission: submission, question: question)
            else
              create(:submission_answer, :incorrect_answer, submission: submission, question: question)
            end
          end
          travel_to day + 5.minutes do
            submission.submit!
          end
        end

        2.times do |i|
          day = i.days.ago.beginning_of_day
          chemistry_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: chemistry, start_at: day, end_at: 1.hour.from_now)
          create(:submission, challenge: chemistry_daily_challenge, user: user, status: :submitted, submitted_at: day + 5.minutes, created_at: day)
        end

        2.times do |i|
          i = 10 + (i * 2)
          day = (i * 2).days.ago.beginning_of_day
          chemistry_daily_challenge = create(:challenge, challenge_type: Challenge.challenge_types[:daily], subject: chemistry, start_at: day, end_at: 1.hour.from_now)
          create(:submission, challenge: chemistry_daily_challenge, user: user, status: :submitted, submitted_at: day + 5.minutes, created_at: day)
        end
      end

      response(200, 'successful') do
        let(:breakdown_for) { 'subject' }
        run_test!
      end
    end
  end

  path '/api/v1/user/reports/mcq' do
    get('MCQ report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :from_date, in: :query, type: :string, required: false, description: "filter start date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "filter end date"
      parameter name: :subject_id, in: :query, type: :string, required: false, description: "filter by subject"

      let!(:biology_questions) { create_list(:question, 10, :mcq_with_answer, subject: biology) }
      let!(:physics_questions) { create_list(:question, 10, :mcq_with_answer, subject: physics) }
      let!(:chemistry_questions) { create_list(:question, 10, :mcq_with_answer, subject: chemistry) }

      before do
        current_time = Time.current
        travel_to current_time - Faker::Number.within(range: 1..6).hours
        biology_submission = create(:submission, challenge: nil, user: user)
        biology_questions.each.with_index do |question, i|
          if i < 3
            create(:submission_answer, :correct_answer, submission: biology_submission, question: question)
          else
            create(:submission_answer, :incorrect_answer, submission: biology_submission, question: question)
          end
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        biology_submission.submit!

        travel_to current_time - Faker::Number.within(range: 1..6).hours
        physics_submission = create(:submission, challenge: nil, user: user)
        physics_questions.each do |question|
          create(:submission_answer, :correct_answer, submission: physics_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        physics_submission.submit!

        travel_to current_time - Faker::Number.within(range: 1..6).hours
        chemistry_submission = create(:submission, challenge: nil, user: user)
        chemistry_questions.each do |question|
          create(:submission_answer, :incorrect_answer, submission: chemistry_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        chemistry_submission.submit!
      end

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['total_correct_questions']).to eq(13)
          expect(data['total_questions_attempted']).to eq(30)
          expect(data['strength_subject']).to eq('Physics')
          expect(data['weakness_subject']).to eq('Chemistry')
          expect(data['stats'].count).to eq(3)
          expect(data['stats'].first['id']).to eq(physics.id)
          expect(data['stats'].first['correct_count']).to eq(10)
          expect(data['stats'].first['total_count']).to eq(10)
          expect(data['stats'].second['id']).to eq(biology.id)
          expect(data['stats'].second['correct_count']).to eq(3)
          expect(data['stats'].second['total_count']).to eq(10)
          expect(data['stats'].third['id']).to eq(chemistry.id)
          expect(data['stats'].third['correct_count']).to eq(0)
          expect(data['stats'].third['total_count']).to eq(10)
          expect(data['avg_completion_seconds']).to_not be_nil
          expect(data['submission_count']).to_not be_nil
          expect(data['avg_score']).to_not be_nil
        end
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
        create(:point_activity, account: user, points: 3, action_type: PointActivity.action_types[:completed_guess_word])
      end

      response(200, 'successful') do
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['total_points']).to eq(168)
          expect(json_response['mcq_points']).to eq(5)
          expect(json_response['daily_challenge_points']).to eq(50)
          expect(json_response['daily_check_in_points']).to eq(10)
          expect(json_response['guess_word_points']).to eq(3)
        end
      end
    end
  end

  path '/api/v1/user/reports/guess_word' do
    get('Guess word report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      before do
        create_list(:guess_word_submission, 3, user: user, status: :in_progress)
        create_list(:guess_word_submission, 5, user: user, status: :success, completed_at: 1.day.ago)
        create(:guess_word_submission, user: user, status: :failed, completed_at: 1.day.ago)
        create(:guess_word_submission, user: user, status: :expired, completed_at: 1.day.ago)
      end

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['submission_count']).to eq(10)
          expect(data['completed_count']).to eq(7)
          expect(data['status_count']).to eq("expired" => 1, "failed" => 1, "in_progress" => 3, "success" => 5)
          expect(data['daily_streak']).to eq(0)
        end
      end
    end
  end

  path '/api/v1/user/reports/subject' do
    get('subject report') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :subject_id, in: :query, type: :string, required: true, description: 'subject id'
      parameter name: :from_date, in: :query, type: :string, required: false, description: "filter start date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "filter end date"

      let(:subject) { biology }
      let(:subject_id) { subject.id }
      let(:topic_chapter1) { create(:topic, subject: subject, name: 'Biology - Chapter 1') }
      let(:topic_chapter2) { create(:topic, subject: subject, name: 'Biology - Chapter 2') }
      let(:topic_chapter3) { create(:topic, subject: subject, name: 'Biology - Chapter 3') }

      let!(:biology_chapter1) do
        create_list(:question, 7, :mcq_with_answer, subject: subject, question_type: :mcq).each do |question|
          create(:question_topic, question: question, topic: topic_chapter1)
        end
      end
      let!(:biology_chapter2) do
        create_list(:question, 5, :mcq_with_answer, subject: subject, question_type: :mcq).each do |question|
          create(:question_topic, question: question, topic: topic_chapter2)
        end
      end
      let!(:biology_chapter3) do
        create_list(:question, 5, :mcq_with_answer, subject: subject, question_type: :mcq).each do |question|
          create(:question_topic, question: question, topic: topic_chapter3)
        end
      end

      before do
        current_time = Time.current
        travel_to current_time - Faker::Number.within(range: 1..6).hours
        biology1_submission = create(:submission, challenge: nil, user: user)
        biology_chapter1.each do |question|
          create(:submission_answer, :incorrect_answer, submission: biology1_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        biology1_submission.submit!

        current_time = Time.current
        travel_to current_time - Faker::Number.within(range: 1..6).hours
        biology2_submission = create(:submission, challenge: nil, user: user)
        biology_chapter2.each do |question|
          create(:submission_answer, :correct_answer, submission: biology2_submission, question: question)
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        biology2_submission.submit!

        current_time = Time.current
        travel_to current_time - Faker::Number.within(range: 1..6).hours
        biology3_submission = create(:submission, challenge: nil, user: user)
        biology_chapter3.each.with_index do |question, i|
          if i <= 2
            create(:submission_answer, :correct_answer, submission: biology3_submission, question: question)
          else
            create(:submission_answer, :incorrect_answer, submission: biology3_submission, question: question)
          end
        end

        travel_to current_time + Faker::Number.within(range: 1..30).minutes
        biology3_submission.submit!
      end

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['subject_name']).to eq(subject.name)
          expect(data['average_time']).to_not be_nil
          expect(data['total_correct_questions']).to eq(8)
          expect(data['total_questions_attempted']).to eq(17)
          expect(data['strength_subject']).to eq('Biology - Chapter 2')
          expect(data['weakness_subject']).to eq('Biology - Chapter 1')
          expect(data['stats'].count).to eq(3)
          expect(data['stats'].first['id']).to eq(topic_chapter2.id)
          expect(data['stats'].first['correct_count']).to eq(5)
          expect(data['stats'].first['total_count']).to eq(5)
          expect(data['stats'].second['id']).to eq(topic_chapter3.id)
          expect(data['stats'].second['correct_count']).to eq(3)
          expect(data['stats'].second['total_count']).to eq(5)
          expect(data['stats'].third['id']).to eq(topic_chapter1.id)
          expect(data['stats'].third['correct_count']).to eq(0)
          expect(data['stats'].third['total_count']).to eq(7)
        end
      end
    end
  end

  path '/api/v1/user/reports/subject_breakdown' do
    get('subject breakdown') do
      tags 'User Reports'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :subject_id, in: :query, type: :string, required: true, description: 'subject id'
      parameter name: :from_date, in: :query, type: :string, required: false, description: "filter start date"
      parameter name: :to_date, in: :query, type: :string, required: false, description: "filter end date"
      parameter name: :breakdown_for, in: :query, type: :string, required: false, description: "Select data point to group by\nbreakdown for option: topic, month, month_topic"

      let(:subject_id) { subject.id }
      let(:breakdown_for) { 'topic' }

      let(:subject) { biology }
      let(:topic_chapter1) { create(:topic, subject: subject, name: 'Biology - Chapter 1') }
      let(:topic_chapter2) { create(:topic, subject: subject, name: 'Biology - Chapter 2') }
      let(:topic_chapter3) { create(:topic, subject: subject, name: 'Biology - Chapter 3') }

      let!(:biology_chapter1) do
        create_list(:question, 7, :mcq_with_answer, subject: subject, question_type: :mcq).each do |question|
          create(:question_topic, question: question, topic: topic_chapter1)
        end
      end
      let!(:biology_chapter2) do
        create_list(:question, 5, :mcq_with_answer, subject: subject, question_type: :mcq).each do |question|
          create(:question_topic, question: question, topic: topic_chapter2)
        end
      end
      let!(:biology_chapter3) do
        create_list(:question, 5, :mcq_with_answer, subject: subject, question_type: :mcq).each do |question|
          create(:question_topic, question: question, topic: topic_chapter3)
        end
      end

      before do
        submission = create(:submission, challenge: nil, user: user)

        topic_chapter1.questions.each.with_index do |question, i|
          if i < 6
            create(:submission_answer, :correct_answer, challenge: nil, submission: submission, question: question)
          else
            create(:submission_answer, :incorrect_answer, challenge: nil, submission: submission, question: question)
          end
        end

        topic_chapter2.questions.each.with_index do |question, i|
          if i < 4
            create(:submission_answer, :correct_answer, challenge: nil, submission: submission, question: question)
          else
            create(:submission_answer, :incorrect_answer, challenge: nil, submission: submission, question: question)
          end
        end

        topic_chapter3.questions.each.with_index do |question, i|
          if i < 3
            create(:submission_answer, :correct_answer, challenge: nil, submission: submission, question: question)
          else
            create(:submission_answer, :incorrect_answer, challenge: nil, submission: submission, question: question)
          end
        end
        submission.submit!
      end

      response(200, 'successful') do
        let(:breakdown_for) { 'month_topic' }
        run_test!
      end
    end
  end
end
