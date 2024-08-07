require 'swagger_helper'

RSpec.describe "api/v1/admin/referral_activities", type: :request do
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:referral_activity) { create(:referral_activity, :user_signup) }
  let(:id) { referral_activity.id }

  path '/api/v1/admin/referral_activities' do
    get('list referral activities') do
      tags 'Admin Referral Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter date range start'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'Filter date range end'
      parameter name: :user_id, in: :query, type: :string, required: false, description: 'Filter by user id'
      parameter name: :referral_source_id, in: :query, type: :string, required: false, description: 'Filter by referral source id'
      parameter name: :referral_source_type, in: :query, type: :string, required: false, description: 'Filter by referral source type'
      parameter name: :referral_type, in: :query, type: :string, required: false, description: 'Filter by referral type'
      parameter name: :voided, in: :query, type: :string, required: false, description: 'Filter by voided'

      response(200, 'successful') do
        before do
          create_list(:referral_activity, 3, :user_signup)
          create_list(:referral_activity, 2, :user_subscription)
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/referral_activities/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show referral activity') do
      tags 'Admin Referral Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/admin/referral_activities/{id}/nullify' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('nullify referral activity') do
      tags 'Admin Referral Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['referral_activity']['voided']).to eq(true)
        end
      end
    end
  end

  path '/api/v1/admin/referral_activities/{id}/revalidate' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    let(:referral_activity) { create(:referral_activity, :user_signup, voided: true) }

    post('revalidate referral activity') do
      tags 'Admin Referral Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['referral_activity']['voided']).to eq(false)
        end
      end
    end
  end
end
