require 'swagger_helper'

RSpec.describe 'api/v1/admin/answers', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:answer).id }

  path '/api/v1/admin/answers' do
    get('list answers') do
      tags 'Admin Answers'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :question_id, in: :query, type: :string, required: false, description: 'Filter by question id'

      response(200, 'successful') do
        before do
          create_list(:answer, 3)
        end

        run_test!
      end
    end

    post('create answers') do
      tags 'Admin Answers'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          answer: {
            type: :object,
            properties: {
              question_id: { type: :string },
              text: { type: :string },
              image: { type: :string },
              display_order: { type: :integer },
              is_correct: { type: :boolean },
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { answer: attributes_for(:answer) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/answers/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show answers') do
      tags 'Admin Answers'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update answers') do
      tags 'Admin Answers'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          answer: {
            type: :object,
            properties: {
              question_id: { type: :string },
              text: { type: :string },
              image: { type: :string },
              display_order: { type: :integer },
              is_correct: { type: :boolean },
              description: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { answer: attributes_for(:answer) } }

        run_test!
      end
    end

    delete('delete answers') do
      tags 'Admin Answers'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
