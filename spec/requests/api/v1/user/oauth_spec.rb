require 'swagger_helper'

RSpec.describe 'api/v1/user/oauth', type: :request do
  let(:user) { create(:user) }

  path '/api/v1/user/oauth/google' do
    post('Sign in with google') do
      tags 'User OAuth'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          id_token: { type: :string }
        }
      }

      let(:data) { { id_token: 'google_id_token' } }
      let(:google_payload) do
        {
          'email' => user.email,
          'name' => user.name,
          'sub' => SecureRandom.uuid,
          'picture' => Faker::Internet.url
        }
      end

      before do
        allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(google_payload)
        allow(ZkloginSaltGenerator).to receive(:new).and_return(double(generate: 'salt'))
      end

      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', schema: { type: :string }, description: 'Bearer token'

        context 'when user email exists' do
          run_test! do |response|
            parsed_response = JSON.parse(response.body)
            expect(parsed_response['meta']['zklogin_salt']).to eq('salt')
          end
        end

        context 'when user email does not exist' do
          run_test! do |response|
            parsed_response = JSON.parse(response.body)
            expect(parsed_response['meta']['zklogin_salt']).to eq('salt')
          end
        end
      end

      response(401, 'unauthorized') do
        let(:user) { create(:user, :sign_in_with_google, active: false) }

        run_test!
      end
    end
  end
end
