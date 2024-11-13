require 'swagger_helper'

RSpec.describe 'api/v1/admin/curriculums', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:curriculum).id }

  path '/api/v1/admin/curriculums' do
    get('list curriculums') do
      tags 'Admin Curriculums'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name or board'

      response(200, 'successful') do
        before do
          create_list(:curriculum, 3)
          create(:curriculum, organization: create(:organization))
        end

        run_test! do |response|
          puts response.body
          data = JSON.parse(response.body)
          expect(data['curriculums']).to all(include("organization_id" => nil))
        end
      end
    end

    post('create curriculums') do
      tags 'Admin Curriculums'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          curriculum: {
            type: :object,
            properties: {
              name: { type: :string },
              board: { type: :string },
              display_order: { type: :integer },
              is_published: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { curriculum: attributes_for(:curriculum) } }

        let(:organization) { create(:organization, :with_admin, admin: user) }

        before do
          # create(:organization_account, account: user, organization: organization)
          user.update(selected_organization: organization)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['curriculum']['organization_id']).to eq organization.id
        end
      end
    end
  end

  path '/api/v1/admin/curriculums/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show curriculums') do
      tags 'Admin Curriculums'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update curriculums') do
      tags 'Admin Curriculums'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          curriculum: {
            type: :object,
            properties: {
              name: { type: :string },
              board: { type: :string },
              display_order: { type: :integer },
              is_published: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { curriculum: attributes_for(:curriculum) } }

        run_test!
      end
    end

    delete('delete curriculums') do
      tags 'Admin Curriculums'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
