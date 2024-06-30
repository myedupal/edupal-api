require 'swagger_helper'

RSpec.describe 'api/v1/user/daily_challenges', type: :request do
  # change the create(:user) to respective user model name
  let(:curriculum) { create(:curriculum, name: 'IGCSE') }
  let(:user) { create(:user, selected_curriculum: curriculum) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:challenge, :published, :daily, :with_questions, subject: create(:subject, curriculum: curriculum), start_at: Time.current).id }

  path '/api/v1/user/daily_challenges' do
    get('list daily challenges') do
      tags 'User Daily Challenges'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :from_start_at, in: :query, type: :string, required: false, description: 'Filter challenge by start_at'
      parameter name: :to_start_at, in: :query, type: :string, required: false, description: 'Filter challenge by start_at'

      description <<-TEXT.squish
        By default, it will return today's daily challenge only.<br>
        If you want to get for example daily challenges for the current month,<br>
        you need to use the filter params 'from_start_at' and 'to_start_at' with the date range.<br>
        The time format should be in ISO8601 format.<br>
        Example: 'from_start_at=2024-03-01T00:00:00+08:00&to_start_at=2024-03-31T23:59:59+08:00' to get daily challenges for March 2024.
      TEXT

      response(200, 'successful') do
        before do
          3.times do
            create(:challenge, :published, :daily, :with_questions, start_at: Time.current, subject: create(:subject, curriculum: curriculum))
          end
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/daily_challenges/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show challenges') do
      tags 'User Daily Challenges'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
