require 'swagger_helper'

RSpec.describe 'api/v1/admin/papers', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:paper).id }

  path '/api/v1/admin/papers' do
    get('list papers') do
      tags 'Admin Papers'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'

      response(200, 'successful') do
        before do
          create_list(:paper, 10)
        end

        run_test!
      end
    end

    post('create papers') do
      tags 'Admin Papers'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          paper: {
            type: :object,
            properties: {
              name: { type: :string },
              subject_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { paper: attributes_for(:paper) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/papers/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show papers') do
      tags 'Admin Papers'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update papers') do
      tags 'Admin Papers'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          paper: {
            type: :object,
            properties: {
              name: { type: :string },
              subject_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { paper: attributes_for(:paper) } }

        run_test!
      end
    end

    delete('delete papers') do
      tags 'Admin Papers'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
