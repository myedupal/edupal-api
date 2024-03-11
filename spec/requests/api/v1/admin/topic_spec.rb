require 'swagger_helper'

RSpec.describe 'api/v1/admin/topics', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:topic).id }

  path '/api/v1/admin/topics' do
    get('list topics') do
      tags 'Admin Topics'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name'

      response(200, 'successful') do
        before do
          create_list(:topic, 3)
        end

        run_test!
      end
    end

    post('create topics') do
      tags 'Admin Topics'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          topic: {
            type: :object,
            properties: {
              name: { type: :string },
              display_order: { type: :integer },
              subject_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { topic: attributes_for(:topic) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/topics/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show topics') do
      tags 'Admin Topics'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update topics') do
      tags 'Admin Topics'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          topic: {
            type: :object,
            properties: {
              name: { type: :string },
              display_order: { type: :integer },
              subject_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { topic: attributes_for(:topic) } }

        run_test!
      end
    end

    delete('delete topics') do
      tags 'Admin Topics'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
