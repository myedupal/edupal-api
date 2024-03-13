require 'swagger_helper'

RSpec.describe 'api/v1/admin/submission_answers', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  # let(:id) { create(:submission_answer).id }

  path '/api/v1/admin/submission_answers' do
    get('list submission answers') do
      tags 'Admin Submission Answers'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :challenge_submission_id, in: :query, type: :string, required: false, description: 'Filter by challenge submission id'
      parameter name: :question_id, in: :query, type: :string, required: false, description: 'Filter by question id'
      parameter name: :user_id, in: :query, type: :string, required: false, description: 'Filter by user id'

      response(200, 'successful') do
        before do
          create_list(:submission_answer, 3)
        end

        run_test!
      end
    end
  end
end
