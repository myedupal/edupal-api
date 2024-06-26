require 'swagger_helper'

RSpec.describe 'api/v1/admin/submissions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:submission).id }

  path '/api/v1/admin/submissions' do
    get('list submissions') do
      tags 'Admin Submissions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :challenge_id, in: :query, type: :string, required: false, description: 'Filter by challenge id'
      parameter name: :user_id, in: :query, type: :string, required: false, description: 'Filter by user id'

      response(200, 'successful') do
        before do
          create_list(:submission, 3)
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/submissions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show submissions') do
      tags 'Admin Submissions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
