require 'swagger_helper'

RSpec.describe 'api/v1/user/organizations', type: :request do
  let(:user) { create(:user) }
  let(:organization_account) { create(:organization_account, account: user, role: :trainee) }
  let(:organization) { organization_account.organization }
  let(:id) { organization.id }
  let(:Authorization) { bearer_token_for(user) }

  path '/api/v1/user/organizations' do
    get('list organizations') do
      tags 'User Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by title'

      response(200, 'successful') do
        before { create_list(:organization_account, 4, account: user, role: :trainee) }

        run_test!
      end
    end
  end

  path '/api/v1/user/organizations/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show organizations') do
      tags 'User Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/organizations/{id}/leave' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('leave organizations') do
      tags 'User Organization'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test! do |_response|
          expect(user.organization_accounts.find_by(organization_id: id)).to be_nil
        end
      end
    end
  end
end

