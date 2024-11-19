require 'swagger_helper'

RSpec.describe 'api/v1/web/organization_invitations', type: :request do
  path '/api/v1/web/organization_invitations/lookup/{code}' do
    parameter name: 'code', in: :path, type: :string, description: 'code'

    get('lookup organization invitations') do
      tags 'User Organization Invitation'
      produces 'application/json'

      before do
        create(:organization_invitation, :group_invite, :trainee)
        create(:organization_invitation, :user_invite, :trainee)
      end

      response(200, 'successful') do
        let(:organization_invitation) { create(:organization_invitation, :group_invite, role: :trainee) }
        let(:code) { organization_invitation.invitation_code }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['organization_invitation']['id']).to eq(organization_invitation.id)
        end
      end

      response(404, 'not found') do
        let(:code) { Faker::Lorem.word }

        run_test!
      end
    end
  end
end
