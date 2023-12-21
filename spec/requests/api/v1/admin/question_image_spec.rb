require 'swagger_helper'

RSpec.describe 'api/v1/admin/question_images', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:question_image).id }

  path '/api/v1/admin/question_images' do
    get('list question images') do
      tags 'Admin Question Images'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :question_id, in: :query, type: :string, required: false, description: 'Filter by question id'

      response(200, 'successful') do
        before do
          create_list(:question_image, 3)
        end

        run_test!
      end
    end

    post('create question images') do
      tags 'Admin Question Images'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          question_image: {
            type: :object,
            properties: {
              question_id: { type: :string },
              image: { type: :string },
              display_order: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { question_image: attributes_for(:question_image) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/question_images/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show question images') do
      tags 'Admin Question Images'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update question images') do
      tags 'Admin Question Images'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          question_image: {
            type: :object,
            properties: {
              question_id: { type: :string },
              image: { type: :string },
              display_order: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { question_image: attributes_for(:question_image) } }

        run_test!
      end
    end

    delete('delete question images') do
      tags 'Admin Question Images'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
