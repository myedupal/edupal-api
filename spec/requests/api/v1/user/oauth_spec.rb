require 'swagger_helper'

RSpec.describe 'api/v1/user/oauth', type: :request do
  let(:user) { create(:user, :sign_in_with_google, password: 'password') }

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
      let(:google_payload) { { 'email' => user.email, 'name' => user.name, 'sub' => user.oauth2_sub, 'picture' => user.oauth2_profile_picture_url } }

      response(200, 'successful', save_request_example: :data) do
        header 'Authorization', schema: { type: :string }, description: 'Bearer token'

        before do
          allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(google_payload)
          allow(ZkloginSaltGenerator).to receive(:new).and_return(double(generate: 'salt'))
        end

        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['meta']['zklogin_salt']).to eq(user.zklogin_salt)
        end
      end

      response(401, 'unauthorized') do
        let(:user) { create(:user, :sign_in_with_google, active: false) }

        before do
          allow(Google::Auth::IDTokens).to receive(:verify_oidc).and_return(google_payload)
        end

        run_test!
      end
    end
  end
end
