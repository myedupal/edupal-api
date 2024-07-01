require 'swagger_helper'

RSpec.describe 'api/v1/admin/plans', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:plan).id }

  path '/api/v1/admin/plans' do
    get('list plans') do
      tags 'Admin Plans'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'

      response(200, 'successful') do
        before do
          create_list(:plan, 3)
        end

        run_test!
      end
    end

    post('create plans') do
      tags 'Admin Plans'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          plan: {
            type: :object,
            properties: {
              name: { type: :string },
              is_published: { type: :string },
              limits: { type: :object },
              plan_type: { type: :string },
              referral_fee_percentage: { type: :number },
              prices_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    amount: { type: :string },
                    billing_cycle: { type: :string, enum: Price.billing_cycles.keys },
                    amount_currency: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { plan: attributes_for(:plan).slice(:name).merge(
            prices_attributes: [{ amount: 15, billing_cycle: 'month' }, { amount: 120, billing_cycle: 'year' }]
          ) }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/plans/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show plans') do
      tags 'Admin Plans'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update plans') do
      tags 'Admin Plans'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          plan: {
            type: :object,
            properties: {
              name: { type: :string },
              is_published: { type: :string },
              limits: { type: :object },
              plan_type: { type: :string },
              referral_fee_percentage: { type: :number },
              prices_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    amount: { type: :string },
                    billing_cycle: { type: :string, enum: Price.billing_cycles.keys },
                    amount_currency: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { plan: attributes_for(:plan).slice(:name) } }

        run_test!
      end
    end

    delete('delete plans') do
      tags 'Admin Plans'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
