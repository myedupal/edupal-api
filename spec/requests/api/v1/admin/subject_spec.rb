require 'swagger_helper'

RSpec.describe 'api/v1/admin/subjects', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:subject).id }

  path '/api/v1/admin/subjects' do
    get('list subjects') do
      tags 'Admin Subjects'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :code, in: :query, type: :string, required: false, description: 'Filter by code'
      parameter name: :name, in: :query, type: :string, required: false, description: 'Filter by name'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name or code'

      response(200, 'successful') do
        before do
          create_list(:subject, 3)
        end

        run_test!
      end
    end

    post('create subjects') do
      tags 'Admin Subjects'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          subject: {
            type: :object,
            properties: {
              name: { type: :string },
              curriculum_id: { type: :string },
              code: { type: :string },
              is_published: { type: :boolean },
              banner: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { subject: attributes_for(:subject) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/subjects/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show subjects') do
      tags 'Admin Subjects'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update subjects') do
      tags 'Admin Subjects'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          subject: {
            type: :object,
            properties: {
              name: { type: :string },
              curriculum_id: { type: :string },
              code: { type: :string },
              is_published: { type: :boolean },
              banner: { type: :string },
              remove_banner: { type: :boolean }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { subject: attributes_for(:subject) } }

        run_test!
      end
    end

    delete('delete subjects') do
      tags 'Admin Subjects'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
