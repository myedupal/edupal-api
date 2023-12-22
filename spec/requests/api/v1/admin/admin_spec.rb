require 'swagger_helper'

RSpec.describe 'api/v1/admin/admins', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:admin).id }

  path '/api/v1/admin/admins' do
    get('list admins') do
      tags 'Admin Admins'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search name, email address'

      response(200, 'successful') do
        before do
          create_list(:admin, 3)
        end

        run_test!
      end
    end

    post('create admins') do
      tags 'Admin Admins'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string },
              name: { type: :string },
              active: { type: :string },
              password: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { admin: attributes_for(:admin) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/admins/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show admins') do
      tags 'Admin Admins'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update admins') do
      tags 'Admin Admins'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string },
              name: { type: :string },
              active: { type: :string },
              password: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { admin: attributes_for(:admin) } }

        run_test!
      end
    end

    delete('delete admins') do
      tags 'Admin Admins'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
