require 'swagger_helper'

RSpec.describe 'api/v1/admin/sessions', type: :request do
  let(:admin) { create(:admin, password: 'password') }

  path '/api/v1/admin/sign_in' do
    post('Sign in') do
      tags 'Admin Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string, example: 'admin@test.com' },
              password: { type: :string, example: 'password' }
            },
            required: %w[email password]
          }
        }
      }
      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', schema: { type: :string }, description: 'Bearer token'

        let(:data) do
          {
            admin: {
              email: admin.email,
              password: 'password'
            }
          }
        end

        run_test!
      end

      response(401, 'unauthorized') do
        let(:data) do
          {
            admin: {
              email: admin.email,
              password: 'wrong_password'
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/sign_out' do
    delete('Sign out') do
      tags 'Admin Sessions'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        let(:Authorization) { bearer_token_for(create(:admin)) }

        run_test!
      end
    end
  end
end
