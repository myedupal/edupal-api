require 'swagger_helper'

RSpec.describe 'api/v1/user/organization_invitations', type: :request do
  let(:user) { create(:user) }
  let(:organization_invitation) { create(:organization_invitation, :group_invite, role: :trainee) }
  let(:id) { organization_invitation.id }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/organization_invitations' do
    get('list organization invitations') do
      tags 'User Organization Invitation'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :invite_code, in: :query, type: :string, required: false, description: 'Find by invite code'
      parameter name: :active, in: :query, type: :boolean, required: false, description: 'Filter by active invitation'
      parameter name: :expired, in: :query, type: :boolean, required: false, description: 'Filter by expired invitation'

      response(200, 'successful') do
        before do
          create_list(:organization_invitation, 3, :group_invite, :trainee)
          create_list(:organization_invitation, 2, :user_invite, :trainee, account: user)
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/organization_invitations/lookup/{code}' do
    parameter name: 'code', in: :path, type: :string, description: 'code'

    get('lookup organization invitations') do
      tags 'User Organization Invitation'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      before do
        create(:organization_invitation, :group_invite, :trainee)
        create(:organization_invitation, :user_invite, :trainee, account: user)
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

  path '/api/v1/user/organization_invitations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show organization invitations') do
      tags 'User Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/organization_invitations/{id}/accept' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('accept organization invitations') do
      tags 'User Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let!(:organization_invitation) { create(:organization_invitation, :group_invite, role: :trainee, used_count: 4) }
        before { allow(ActiveRecord::Base).to receive(:transaction).and_yield }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['organization_invitation']['used_count']).to eq(5)

        end
      end
    end
  end

  path '/api/v1/user/organization_invitations/{id}/reject' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('accept organization invitations') do
      tags 'User Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let!(:organization_invitation) { create(:organization_invitation, :user_invite, role: :trainee, account: user) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['organization_invitation']['used_count']).to eq(0)
          expect(data['organization_invitation']['max_uses']).to eq(0)
        end
      end

      response(404, 'not found') do
        let(:organization_invitation) { create(:organization_invitation, :user_invite, role: :trainee, account: create(:user)) }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:organization_invitation) { create(:organization_invitation, :group_invite, role: :trainee) }

        run_test!
      end
    end
  end
end
