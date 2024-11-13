require 'swagger_helper'

RSpec.describe 'api/v1/admin/organization_accounts', type: :request do
  let(:admin) { create(:admin, super_admin: false) }
  let(:organization) { create(:organization, owner: admin) }
  before { admin.update(selected_organization: organization) }
  let(:trainer) { create(:organization_account, account: create(:admin, super_admin: false), organization: organization, role: :trainer).account }
  let(:organization_account) { create(:organization_account, organization: organization, role: :trainee) }
  let(:id) { organization_account.id }
  let(:Authorization) { bearer_token_for(admin) }

  path '/api/v1/admin/organization_accounts' do
    get('list organization accounts') do
      tags 'Admin Organization Account'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :selected_organization, in: :query, type: :boolean, required: false, description: 'Filter by selected organization'
      parameter name: :organization_id, in: :query, type: :string, required: false, description: 'Filter by organization id'
      parameter name: :role, in: :query, type: :string, required: false, description: 'Filter by role'

      response(200, 'successful') do
        before do
          create_list(:organization_account, 3, organization: organization)
        end

        run_test!
      end
    end

    post('create organization accounts') do
      tags 'Admin Organization Account'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          organization_account: {
            type: :object,
            properties: {
              organization_id: { type: :string },
              account_id: { type: :string },
              role: { type: :string, enum: OrganizationAccount.roles }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:admin) { create(:admin, super_admin: true) }
        let(:data) do
          {
            organization_account: {
              organization_id: organization.id,
              account_id: create(:admin).id,
              role: :admin
            }
          }
        end

        run_test!
      end

      response(403, 'unauthorized') do
        let(:data) do
          {
            organization_account:
              attributes_for(:organization_account, organization: organization)
                .slice(:organization_id, :account_id, :role)
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/organization_accounts/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show organization accounts') do
      tags 'Admin Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update organization accounts') do
      tags 'Admin Organization'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          organization_account: {
            type: :object,
            properties: {
              organization_id: { type: :string },
              account_id: { type: :string },
              role: { type: :string, enum: OrganizationAccount.roles }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:organization_account) { create(:organization_account, organization: organization, role: :trainer) }
        let(:data) { { organization_account: { role: :admin } } }

        run_test!
      end

      context 'with account' do
        let(:admin) { create(:admin, super_admin: true) }
        let(:organization_account) { create(:organization_account, organization: organization, role: :trainer) }
        let(:another_account) { create(:admin, super_admin: false) }
        let(:data) { { organization_account: { account_id: another_account.id } } }

        it 'cannot change account id' do
          put api_v1_admin_organization_account_url(organization_account), headers: { Authorization: bearer_token_for(admin) }, params: data

          expect(response).to have_http_status(:unprocessable_entity)
          expect(organization_account.reload).not_to eq(another_account)
        end
      end

      context 'when the user is a trainer' do
        let(:Authorization) { bearer_token_for(trainer) }
        before { trainer.update(selected_organization: organization) }

        context 'when the account is trainee' do
          response(403, 'unauthorized') do
            let(:organization_account) { create(:organization_account, organization: organization, role: :trainee) }
            let(:data) { { organization_account: { role: :trainer } } }

            run_test! do |response|
              expect(organization_account.reload.role).to eq('trainee')
            end
          end
        end

        context 'when the account is trainer' do
          let(:organization_account) { create(:organization_account, organization: organization, role: :trainer) }
          let(:data) { { organization_account: { role: :admin } } }

          it 'is not allowed to update to admin' do
            put api_v1_admin_organization_account_url(organization_account), headers: { Authorization: bearer_token_for(trainer) }, params: data

            expect(response).to have_http_status(:forbidden)
            expect(organization_account.reload.role).to eq('trainer')
          end
        end

        context 'when the account is admin' do
          let(:organization_account) { create(:organization_account, organization: organization, role: :admin) }
          let(:data) { { organization_account: { role: :trainer } } }

          it 'is not allowed to update to trainer' do
            put api_v1_admin_organization_account_url(organization_account), headers: { Authorization: bearer_token_for(trainer) }, params: data

            expect(response).to have_http_status(:forbidden)
            expect(organization_account.reload.role).to eq('admin')
          end
        end
      end
    end

    delete('delete organization accounts') do
      tags 'Admin Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:organization_account) { create(:organization_account, organization: organization, role: :admin) }
        before { trainer.update(selected_organization: organization) }

        run_test!
      end

      response(403, 'unauthorized') do
        let(:Authorization) { bearer_token_for(trainer) }
        let(:organization_account) { create(:organization_account, organization: organization, role: :trainer) }
        before { trainer.update(selected_organization: organization) }

        run_test!
      end
    end
  end
end
