require 'swagger_helper'

RSpec.describe 'api/v1/admin/organizations', type: :request do
  let(:admin) { create(:admin, super_admin: false) }
  let(:organization) { create(:organization, owner: admin) }
  let(:id) { organization.id }
  let(:Authorization) { bearer_token_for(admin) }

  path '/api/v1/admin/organizations' do
    get('list organizations') do
      tags 'Admin Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by title'

      response(200, 'successful') do
        before do
          create_list(:organization, 3, owner: admin, status: :active)
        end

        run_test!
      end
    end

    post('create organization') do
      tags 'Admin Organization'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          organization: {
            type: :object,
            properties: {
              owner_id: { type: :string },
              title: { type: :string },
              description: { type: :string },
              icon_image: { type: :string },
              icon_banner: { type: :string },
              status: { type: :string },
              maximum_headcount: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:admin) { create(:admin, super_admin: true) }
        let(:data) { { organization: attributes_for(:organization, owner: admin).slice(:owner_id, :title, :description, :status, :maximum_headcount) } }

        run_test!
      end

      response(403, 'unauthorized') do
        let(:admin) { create(:admin, super_admin: false) }
        let(:data) { { organization: attributes_for(:organization, owner: admin).slice(:owner_id, :title, :description, :status, :maximum_headcount) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/organizations/setup' do
    post('setup organization') do
      tags 'Admin Organization'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          organization: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              icon_image: { type: :string },
              icon_banner: { type: :string },
              maximum_headcount: { type: :string }
            }
          }
        }
      }

      response(200, 'successful') do
        let(:admin) { create(:admin, super_admin: false) }
        let(:data) { { organization: attributes_for(:organization, owner: nil).slice(:title, :description, :maximum_headcount).merge(status: :active) } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['organization']['status']).to eq('pending')
        end
      end
    end
  end

  path '/api/v1/admin/organizations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show organizations') do
      tags 'Admin Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update organizations') do
      tags 'Admin Organization'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          account: {
            type: :object,
            properties: {
              owner_id: { type: :string },
              title: { type: :string },
              description: { type: :string },
              icon_image: { type: :string },
              icon_banner: { type: :string },
              status: { type: :string },
              maximum_headcount: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:admin) { create(:admin, super_admin: false) }
        let(:organization) { create(:organization, owner: admin, status: :pending) }
        let(:data) { { organization: attributes_for(:organization).slice(:title, :description).merge(status: :active) } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['organization']['status']).to eq('pending')
        end
      end
    end

    delete('delete organizations') do
      tags 'Admin Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/admin/organizations/{id}/leave' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('leave organizations') do
      tags 'Admin Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        let(:another_admin) { create(:admin) }
        let(:Authorization) { bearer_token_for(another_admin) }
        before { create(:organization_account, organization: organization, account: another_admin) }

        run_test! do |_response|
          expect(another_admin.organization_accounts.find_by(organization_id: id)).to be_nil
        end
      end

      response(422, 'unprocessable entity') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error_messages'].first).to eq("You cannot leave your own organization")
        end
      end
    end
  end
end
