require 'swagger_helper'

RSpec.describe 'api/v1/user/point_activities', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/point_activities' do
    get('list point_activities') do
      tags 'User Point Activities'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false,
                description: 'Sort by column name. When sort_by is topic, it will be sorted by topic display order ASC (default) and question number ASC.'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :action_type, in: :query, type: :string, required: false, description: "Filter by action type. Available values are #{PointActivity.action_types.keys.join(', ')}"
      parameter name: :from_date, in: :query, type: :string, required: false, description: 'From date created_at'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'To date created_at'

      response(200, 'successful') do
        before do
          daily_check_in = create(:daily_check_in, user: user)
          create(:point_activity, action_type: PointActivity.action_types[:daily_check_in], account: user, points: Setting.daily_check_in_points, activity: daily_check_in)
          create(:submission_answer, :correct_answer, user: user, challenge_submission: nil)
          submission = create(:challenge_submission, :with_submission_answers, user: user)
          submission.submit!
        end

        run_test!
      end
    end
  end
end
