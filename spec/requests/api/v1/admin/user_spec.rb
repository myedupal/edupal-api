require 'swagger_helper'

RSpec.describe 'api/v1/admin/user', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:user).id }

  path '/api/v1/admin/users' do
    get('list user') do
      tags 'Admin Users'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search name, email address'

      response(200, 'successful') do
        before do
          create_list(:user, 3)
        end

        run_test!
      end
    end

    post('create user') do
      tags 'Admin Users'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              name: { type: :string },
              active: { type: :boolean },
              password: { type: :string }
            }
          }
        }
      }

      response(200, 'success', save_request_example: :data) do
        let(:data) { { user: attributes_for(:user).slice(:email, :name, :password) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show user') do
      tags 'Admin Users'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update user') do
      tags 'Admin Users'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              name: { type: :string },
              active: { type: :boolean },
              password: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { user: attributes_for(:user).slice(:email, :name) } }

        run_test!
      end
    end

    delete('delete user') do
      tags 'Admin Users'
      security [{ bearerAuth: nil }]

      response(403, 'forbidden') do
        run_test!
      end
    end
  end
end
