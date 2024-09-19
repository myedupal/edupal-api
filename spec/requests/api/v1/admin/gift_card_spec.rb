require 'swagger_helper'

RSpec.describe 'api/v1/admin/gift_cards', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:gift_card).id }

  path '/api/v1/admin/gift_cards' do
    get('list gift cards') do
      tags 'Admin Gift Cards'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name'
      parameter name: :plan_id, in: :query, type: :string, required: false, description: 'Filter by plan id'

      response(200, 'successful') do
        before do
          create_list(:gift_card, 3)
        end

        run_test!
      end
    end

    post('create gift cards') do
      tags 'Admin Gift Cards'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          gift_card: {
            type: :object,
            properties: {
              name: { type: :string },
              remark: { type: :string },
              plan_id: { type: :string },
              redemption_limit: { type: :integer },
              expires_at: { type: :string },
              duration: { type: :integer, description: 'Duration in days' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { gift_card: attributes_for(:gift_card).slice(:name, :remark, :plan_id, :redemption_limit) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/gift_cards/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show gift cards') do
      tags 'Admin Gift Cards'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update gift cards') do
      tags 'Admin Gift Cards'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          gift_card: {
            type: :object,
            properties: {
              name: { type: :string },
              remark: { type: :string },
              plan_id: { type: :string },
              redemption_limit: { type: :integer },
              expires_at: { type: :string },
              duration: { type: :integer, description: 'Duration in days' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { gift_card: attributes_for(:gift_card).slice(:redemption_limit) } }

        run_test!
      end
    end

    delete('delete gift cards') do
      tags 'Admin Gift Cards'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
