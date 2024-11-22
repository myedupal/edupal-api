require 'swagger_helper'

RSpec.describe 'api/v1/admin/organization_invitations', type: :request do
  let(:admin) { create(:admin, super_admin: false) }
  let(:organization) { create(:organization, owner: admin) }
  before { admin.update(selected_organization: organization) }
  let(:trainer) { create(:organization_account, account: create(:admin, super_admin: false), organization: organization, role: :trainer).account }
  let(:organization_invitation) { create(:organization_invitation, organization: organization, role: :trainee) }
  let(:id) { organization_invitation.id }
  let(:Authorization) { bearer_token_for(admin) }

  path '/api/v1/admin/organization_invitations' do
    get('list organization invitations') do
      tags 'Admin Organization Invitation'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :selected_organization, in: :query, type: :boolean, required: false, description: 'Filter by selected organization'
      parameter name: :organization_id, in: :query, type: :string, required: false, description: 'Filter by organization id'
      parameter name: :code, in: :query, type: :string, required: false, description: 'Search by code'
      parameter name: :label, in: :query, type: :string, required: false, description: 'Search by label'
      parameter name: :invite_type, in: :query, type: :string, required: false, description: 'Filter by invite_type'
      parameter name: :role, in: :query, type: :string, required: false, description: 'Filter by role'
      parameter name: :created_by_id, in: :query, type: :string, required: false, description: 'Filter by created_by id'

      response(200, 'successful') do
        before do
          create_list(:organization_invitation, 3, organization: organization)
          create_list(:organization_invitation, 2, :user_invite, :trainer, organization: organization)
        end

        run_test!
      end
    end

    post('create organization invitations') do
      tags 'Admin Organization Invitation'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          organization_invitation: {
            type: :object,
            properties: {
              organization_id: { type: :string },
              account_id: { type: :string },
              email: { type: :string },
              invite_type: { type: :string, enum: OrganizationInvitation.invite_types },
              label: { type: :string },
              invitation_code: { type: :string },
              used_count: { type: :string },
              max_uses: { type: :string },
              role: { type: :string, enum: OrganizationInvitation.roles },
              send_mail: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :group_invite, :trainee, organization: organization)
                .slice(:organization_id, :invite_type, :label, :used_count, :max_uses, :role)
          }
        end

        run_test!
      end

      response(403, 'unauthorized') do
        let(:another_organization) { create(:organization) }
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :group_invite, :trainee, organization: another_organization)
                .slice(:organization_id, :invite_type, :label, :used_count, :max_uses, :role)
          }
        end

        run_test!
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :group_invite, :trainee, organization: organization)
                .slice(:organization_id, :invite_type, :label, :used_count, :max_uses, :role).merge(role: :admin)
          }
        end
        before { trainer.update(selected_organization: organization) }

        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :user_invite, :trainee, organization: organization)
                .slice(:invite_type, :label, :used_count, :max_uses, :role, :account_id, :email).merge(account_id: create(:user).id)
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/organization_invitations/bulk_create' do
    post('bulk create organization invitations') do
      tags 'Admin Organization Invitation'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        required: [:organization_invitations],
        properties: {
          organization_invitations: {
            type: :array,
            items: {
              type: :object,
              required: [:organization_id, :invite_type, :role],
              properties: {
                organization_id: { type: :string },
                account_id: { type: :string },
                email: { type: :string },
                invite_type: { type: :string, enum: OrganizationInvitation.invite_types },
                label: { type: :string },
                used_count: { type: :integer, minimum: 0 },
                max_uses: { type: :integer, minimum: 1 },
                role: { type: :string, enum: OrganizationInvitation.roles },
                send_mail: { type: :boolean }
              }
            },
            minItems: 1
          }
        }
      }

      response(200, 'successful') do
        let(:labels) { 3.times.map { Faker::Lorem.words(number: 3).join(' ') } }
        let(:organization_invitations) do
          labels.map do |label|
            attributes_for(:organization_invitation, :group_invite, :trainee, organization: organization)
              .slice(:organization_id, :invite_type, :used_count, :max_uses, :role).merge(label: label)
          end
        end
        let(:data) { { organization_invitations: organization_invitations } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['organization_invitations'].count).to eq(3)
          expect(data['organization_invitations'].pluck('organization_id')).to eq([organization.id] * 3)
          expect(data['organization_invitations'].pluck('label')).to eq(labels)
        end
      end

      response(422, 'unprocessable entity') do
        let(:label) { Faker::Lorem.words(number: 3).join(' ') }
        let(:data) do
          {
            organization_invitations: [
              attributes_for(:organization_invitation, :group_invite, :trainee, organization: organization)
                .slice(:organization_id, :invite_type, :used_count, :max_uses, :role).merge(label: label),
              attributes_for(:organization_invitation, :user_invite, :trainee, organization: organization)
                .slice(:organization_id, :invite_type, :used_count, :max_uses, :role).merge(account_id: create(:user).id, email: create(:user).email)
            ]
          }
        end

        run_test! do
          expect(OrganizationInvitation.find_by(label: label)).to be_nil
        end
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:data) do
          {
            organization_invitations: [
              attributes_for(:organization_invitation, :group_invite, :trainer, organization: organization)
            ]
          }
        end
        before { trainer.update(selected_organization: organization) }

        run_test!
      end
    end
  end

  path '/api/v1/admin/organization_invitations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show organization invitations') do
      tags 'Admin Organization Invitation'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update organization invitations') do
      tags 'Admin Organization Invitation'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          organization_invitation: {
            type: :object,
            properties: {
              organization_id: { type: :string },
              account_id: { type: :string },
              email: { type: :string },
              invite_type: { type: :string, enum: OrganizationInvitation.invite_types },
              label: { type: :string },
              invitation_code: { type: :string },
              used_count: { type: :string },
              max_uses: { type: :string },
              role: { type: :string, enum: OrganizationInvitation.roles }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:organization_invitation) { create(:organization_invitation, organization: organization, role: :trainee) }
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :group_invite, :trainer, organization: organization)
                .slice(:organization_id, :invite_type, :label, :used_count, :max_uses, :role)
          }
        end

        run_test!
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:organization_invitation) { create(:organization_invitation, organization: organization, role: :trainee) }
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :group_invite, :trainer, organization: organization)
                .slice(:organization_id, :invite_type, :label, :used_count, :max_uses, :role)
          }
        end
        before { trainer.update(selected_organization: organization) }

        run_test! do |_response|
          expect(organization_invitation.reload.role).to eq('trainee')
        end
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:organization_invitation) { create(:organization_invitation, organization: organization, role: :admin) }
        let(:data) do
          {
            organization_invitation:
              attributes_for(:organization_invitation, :group_invite, :trainer, organization: organization)
                .slice(:organization_id, :invite_type, :label, :used_count, :max_uses, :role)
          }
        end
        before { trainer.update(selected_organization: organization) }

        run_test!
      end
    end

    delete('delete organization invitations') do
      tags 'Admin Organization Invitation'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:organization_invitation) { create(:organization_invitation, organization: organization, role: :trainer) }
        before { trainer.update(selected_organization: organization) }

        run_test!
      end
    end
  end
end
