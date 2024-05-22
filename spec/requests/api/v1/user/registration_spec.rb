require 'swagger_helper'

RSpec.describe 'api/v1/user/registrations', type: :request do
  path '/api/v1/user/' do
    post('Register user') do
      tags 'User Registrations'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string },
              name: { type: :string },
              phone_number: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', schema: { type: :string }, description: 'Bearer token'
        let(:data) { { user: attributes_for(:user) } }

        run_test!
      end
    end
  end
end
