require 'swagger_helper'

RSpec.describe "api/v1/user/referral_activities", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:referral_activity) { create(:referral_activity, :user_signup, user: user) }
  let(:id) { referral_activity.id }

  path '/api/v1/user/referral_activities' do
    get('list referral activities') do
      tags 'User Referral Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter date range start'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'Filter date range end'
      parameter name: :referral_type, in: :query, type: :string, required: false, description: 'Filter by referral type'

      response(200, 'successful') do
        before do
          create_list(:referral_activity, 2, :user_signup, user: user)
          create_list(:referral_activity, 1, :user_subscription, user: user)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/referral_activities/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show referral activity') do
      tags 'User Referral Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
