require 'swagger_helper'

RSpec.describe 'api/v1/admin/reports', type: :request do
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }

  before do
    travel_to(Time.zone.parse('2024-07-15'))
  end

  path '/api/v1/admin/reports/user_current_streaks_count' do
    get('show current users streak') do
      tags 'Admin Report'
      produces 'application/json'
      security [{ bearerAuth: nil }]
      description <<~DOC
        Show the users ongoing streak count
        in format of "streak count: users count"
        specific shows count of users with specific streaks
        sum shows sum count of users with below streak counts
      DOC

      parameter name: :specific_count, in: :query, type: :integer, required: false, description: 'How many specific streaks to count'
      parameter name: :sum_ranges, in: :query, type: :integer, required: false, description: 'Ranges to sum, use comma seperated format: "7,14", this overwrites all sum_* parameters'
      parameter name: :sum_times, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the times to multiply the interval'
      parameter name: :sum_interval, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the base interval'
      parameter name: :sum_prepend, in: :query, type: :integer, required: false, description: 'Ranges to sum, Prepend with 0 to N days'

      response(200, 'successful') do
        before do
          [1, 2, 3, 7].map do |i|
            create(:user, daily_streak: i)
          end
          [7, 14, 21, 49].map do |i|
            create(:user, daily_streak: i)
          end
          create(:user, daily_streak: 0)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['specific'].keys).to eq(%w[1 2 3 7])
          expect(data['specific']['1']).to eq(1)
          expect(data['specific']['2']).to eq(1)
          expect(data['specific']['3']).to eq(1)
          expect(data['specific']['7']).to eq(2)

          expect(data['sum'].keys).to eq(%w[7 14 21 28 35 42 over])
          expect(data['sum']['7']).to eq(5)
          expect(data['sum']['14']).to eq(6)
          expect(data['sum']['21']).to eq(7)
          expect(data['sum']['over']).to eq(1)
        end
      end
    end
  end

  path '/api/v1/admin/reports/user_max_streaks_count' do
    get('show max users streak') do
      tags 'Admin Report'
      produces 'application/json'
      security [{ bearerAuth: nil }]
      description "Show users maximum streak"

      parameter name: :specific_count, in: :query, type: :integer, required: false, description: 'How many specific streaks to count'
      parameter name: :sum_ranges, in: :query, type: :integer, required: false, description: 'Ranges to sum, use comma seperated format: "7,14", this overwrites all sum_* parameters'
      parameter name: :sum_times, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the times to multiply the interval'
      parameter name: :sum_interval, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the base interval'
      parameter name: :sum_prepend, in: :query, type: :integer, required: false, description: 'Ranges to sum, Prepend with 0 to N days'

      response(200, 'successful') do
        before do
          [1, 2, 7, 10].map do |i|
            create(:user, maximum_streak: i)
          end

          [10, 20, 60].map do |i|
            create(:user, maximum_streak: i)
          end

          create(:user, maximum_streak: 0)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['specific'].keys).to eq(%w[1 2 7 10])
          expect(data['specific'].values).to eq([1, 1, 1, 2])

          expect(data['sum'].keys).to eq(%w[10 20 30 40 50 over])
          expect(data['sum'].values).to eq([5, 6, 6, 6, 6, 1])
        end
      end
    end
  end

  path '/api/v1/admin/reports/user_recent_check_in_count' do
    get('show users recent check in count') do
      tags 'Admin Report'
      produces 'application/json'
      security [{ bearerAuth: nil }]
      description <<~DOC
        Show the recent user check in count
        in format of "day ago: check in count"
        sum shows sum of unique user check in made in today-N days ago
        monthly shows count of unique user check in made in at N months ago
      DOC

      parameter name: :sum_ranges, in: :query, type: :integer, required: false, description: 'Ranges to sum, use comma seperated format: "7,14", this overwrites all sum_* parameters'
      parameter name: :sum_times, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the times to multiply the interval'
      parameter name: :sum_interval, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the base interval'
      parameter name: :sum_prepend, in: :query, type: :integer, required: false, description: 'Ranges to sum, Prepend with 0 to N days'
      parameter name: :specific_count, in: :query, type: :integer, required: false, description: 'How many specific streaks to count'
      parameter name: :months, in: :query, type: :integer, required: false, description: 'How many past months to summarize'

      response(200, 'successful') do
        let(:specific_count) { 7 }
        let(:sum_times) { 6 }
        let(:months) { 6 }
        before do
          user = create(:user)
          create(:daily_check_in, date: 0.days.ago, user: user)
          create(:daily_check_in, date: 1.day.ago, user: user)
          create(:daily_check_in, date: 2.days.ago, user: user)
          create(:daily_check_in, date: 1.month.ago, user: user)
          create(:daily_check_in, date: 2.months.ago, user: user)

          [1, 2, 3, 7, 8].map do |i|
            create(:daily_check_in, date: i.days.ago)
          end

          [1, 2, 6].map do |i|
            create(:daily_check_in, date: i.months.ago)
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['sum'].keys).to eq(%w[0 1 2 3 7 14 21 28 35 42])
          expect(data['sum'].values).to eq([1, 2, 3, 4, 5, 6, 6, 6, 7, 7])
          expect(data['monthly'].keys).to eq(%w[0 1 2 3 4 5 6])
          expect(data['monthly'].values).to eq([6, 2, 2, 0, 0, 0, 1])
        end
      end
    end
  end

  path '/api/v1/admin/reports/user_recent_submission_count' do
    get('show users recent submission in count') do
      tags 'Admin Report'
      produces 'application/json'
      security [{ bearerAuth: nil }]
      description <<~DOC
        Show the recent user submission count
        in format of "day ago: check in count"
        sum shows sum of unique user submission made in today-N days ago
        monthly shows count of unique user submission made in at N months ago
      DOC

      parameter name: :sum_ranges, in: :query, type: :integer, required: false, description: 'Ranges to sum, use comma seperated format: "7,14", this overwrites all sum_* parameters'
      parameter name: :sum_times, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the times to multiply the interval'
      parameter name: :sum_interval, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the base interval'
      parameter name: :sum_prepend, in: :query, type: :integer, required: false, description: 'Ranges to sum, Prepend with 0 to N days'
      parameter name: :months, in: :query, type: :integer, required: false, description: 'How many months to count'

      response(200, 'successful') do
        let(:sum_prepend) { 3 }
        let(:sum_times) { 6 }
        let(:months) { 6 }
        before do
          user = create(:user)
          create(:submission, submitted_at: 0.days.ago, user: user)
          create(:submission, submitted_at: 1.day.ago, user: user)
          create(:submission, submitted_at: 2.days.ago, user: user)
          create(:submission, submitted_at: 1.month.ago, user: user)
          create(:submission, submitted_at: 2.months.ago, user: user)

          [1, 2, 3, 7, 8].map do |i|
            create(:submission, submitted_at: i.days.ago)
          end

          [1, 2, 6].map do |i|
            create(:submission, submitted_at: i.months.ago)
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['sum'].keys).to eq(%w[0 1 2 3 7 14 21 28 35 42])
          expect(data['sum'].values).to eq([1, 2, 3, 4, 5, 6, 6, 6, 7, 7])
          expect(data['monthly'].keys).to eq(%w[0 1 2 3 4 5 6])
          expect(data['monthly'].values).to eq([6, 2, 2, 0, 0, 0, 1])
        end
      end
    end
  end

  path '/api/v1/admin/reports/submission_recent_count' do
    get('show recent submission count') do
      tags 'Admin Report'
      produces 'application/json'
      security [{ bearerAuth: nil }]
      description <<~DOC
        Show the recent submission count
      DOC

      parameter name: :sum_ranges, in: :query, type: :integer, required: false, description: 'Ranges to sum, use comma seperated format: "7,14", this overwrites all sum_* parameters'
      parameter name: :sum_times, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the times to multiply the interval'
      parameter name: :sum_interval, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the base interval'
      parameter name: :sum_prepend, in: :query, type: :integer, required: false, description: 'Ranges to sum, Prepend with 0 to N days'
      parameter name: :months, in: :query, type: :integer, required: false, description: 'How many past months to summarize'

      response(200, 'successful') do
        let(:sum_times) { 2 }
        let(:sum_prepend) { 3 }
        let(:months) { 3 }
        before do
          user = create(:user)
          create(:submission, submitted_at: 0.days.ago, user: user)
          create(:submission, submitted_at: 1.day.ago, user: user)
          create(:submission, submitted_at: 2.days.ago, user: user)
          create(:submission, submitted_at: 3.days.ago, user: user)

          create(:submission, submitted_at: 1.month.ago, user: user)
          create(:submission, submitted_at: 2.months.ago, user: user)

          [1, 2].map do |i|
            create(:submission, submitted_at: i.days.ago)
          end

          [1, 2, 3].map do |i|
            create(:submission, submitted_at: i.months.ago)
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['sum'].keys).to eq(%w[0 1 2 3 7 14])
          expect(data['sum'].values).to eq([1, 3, 5, 6, 6, 6])
          expect(data['monthly'].keys).to eq(%w[0 1 2 3])
          expect(data['monthly'].values).to eq([6, 2, 2, 1])
        end
      end
    end
  end

  path '/api/v1/admin/reports/point_activity_recent_count' do
    get('show recent activity count') do
      tags 'Admin Report'
      produces 'application/json'
      security [{ bearerAuth: nil }]
      description <<~DOC
        Show the recent point activity count by types
      DOC

      parameter name: :sum_ranges, in: :query, type: :integer, required: false, description: 'Ranges to sum, use comma seperated format: "7,14", this overwrites all sum_* parameters'
      parameter name: :sum_times, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the times to multiply the interval'
      parameter name: :sum_interval, in: :query, type: :integer, required: false, description: 'Ranges to sum, specifies the base interval'
      parameter name: :sum_prepend, in: :query, type: :integer, required: false, description: 'Ranges to sum, Prepend with 0 to N days'
      parameter name: :months, in: :query, type: :integer, required: false, description: 'How many past months to summarize'

      response(200, 'successful') do
        let(:sum_prepend) { 2 }
        let(:sum_times) { 1 }
        let(:months) { 2 }
        before do
          user = create(:user)
          another_user = create(:user)
          4.times do |i|
            create(:point_activity, action_type: :daily_check_in, created_at: i.day.ago, user: user)
          end
          create(:point_activity, action_type: :daily_challenge, created_at: 0.days.ago, user: user)
          create(:point_activity, action_type: :answered_question, created_at: 0.days.ago, user: another_user)
          create(:point_activity, action_type: :redeem, created_at: 0.days.ago, user: another_user)
          create(:point_activity, action_type: :redeem, created_at: 3.days.ago, user: user)

          create(:point_activity, action_type: :daily_check_in, created_at: 1.month.ago, user: user)
          create(:point_activity, action_type: :daily_check_in, created_at: 1.month.ago, user: another_user)
          create(:point_activity, action_type: :daily_challenge, created_at: 1.month.ago, user: another_user)
          create(:point_activity, action_type: :answered_question, created_at: 1.month.ago, user: another_user)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['sum'].keys).to eq(%w[0 1 2 7])
          expect(data['sum']['0']).to eq({ 'answered_question' => 1, 'daily_challenge' => 1, 'daily_check_in' => 1, 'redeem' => 1 })
          expect(data['sum']['1']).to eq({ 'answered_question' => 1, 'daily_challenge' => 1, 'daily_check_in' => 2, 'redeem' => 1 })
          expect(data['sum']['2']).to eq({ 'answered_question' => 1, 'daily_challenge' => 1, 'daily_check_in' => 3, 'redeem' => 1 })
          expect(data['sum']['7']).to eq({ 'answered_question' => 1, 'daily_challenge' => 1, 'daily_check_in' => 4, 'redeem' => 2 })

          expect(data['monthly'].keys).to eq(%w[0 1 2])
          expect(data['monthly']['0']).to eq({ 'answered_question' => 1, 'daily_challenge' => 1, 'daily_check_in' => 4, 'redeem' => 2 })
          expect(data['monthly']['1']).to eq({ 'answered_question' => 1, 'daily_challenge' => 1, 'daily_check_in' => 2 })
          expect(data['monthly']['2']).to eq({})
        end
      end
    end
  end
end
