require 'swagger_helper'

RSpec.describe 'api/v1/admin/subscriptions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/admin/subscriptions' do
    get('list subscriptions') do
      tags 'Admin Subscriptions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :plan_id, in: :query, type: :string, required: false, description: 'Filter by plan id'
      parameter name: :user_id, in: :query, type: :string, required: false, description: 'Filter by user id'

      response(200, 'successful') do
        before do
          create_list(:subscription, 3)
        end

        run_test!
      end
    end
  end
end
