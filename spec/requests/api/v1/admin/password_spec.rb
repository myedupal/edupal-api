require 'swagger_helper'

RSpec.describe 'api/v1/admin/passwords', type: :request do
  path '/api/v1/admin/passwords' do
    post('Send Reset Password Token') do
      tags 'Admin Reset Passwords'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              email: { type: :string, format: 'email', example: 'admin@test.com' }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          {
            admin: {
              email: create(:admin).email
            }
          }
        end

        run_test!
      end

      response(422, 'wrong email/phone number') do
        let(:data) do
          {
            admin: {
              email: 'wrong_email@email.com'
            }
          }
        end
        run_test!
      end
    end

    put('Reset Password with Token') do
      tags 'Admin Reset Passwords'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          admin: {
            type: :object,
            properties: {
              reset_password_token: { type: :string },
              password: { type: :string, example: 'password' },
              password_confirmation: { type: :string, example: 'password' }
            },
            required: [:password, :reset_password_token]
          }
        }
      }
      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          {
            admin: {
              reset_password_token: '123456',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        before do
          admin = create(:admin)
          hashed_token = Devise.token_generator.digest(admin, :reset_password_token, 123_456)
          admin.assign_attributes(
            reset_password_token: hashed_token,
            reset_password_sent_at: Time.now.utc
          )
          admin.save(validate: false)
        end

        run_test!
      end

      response(422, 'wrong token') do
        let(:data) do
          {
            admin: {
              reset_password_token: '123456',
              password: 'password123',
              password_confirmation: 'password123'
            }
          }
        end

        run_test!
      end
    end
  end
end
