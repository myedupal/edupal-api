require 'swagger_helper'

RSpec.describe 'api/v1/user/activity_questions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:activity_question, user: user).id }

  path '/api/v1/user/activity_questions' do
    get('list activity questions') do
      tags 'User Activity Questions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :activity_id, in: :query, type: :string, required: false, description: 'Filter by Activity id'
      parameter name: :question_id, in: :query, type: :string, required: false, description: 'Filter by Question id'

      response(200, 'successful') do
        before do
          create_list(:activity_question, 3, user: user)
        end

        run_test!
      end
    end

    post('create activity questions') do
      tags 'User Activity Questions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          activity_question: {
            type: :object,
            properties: {
              activity_id: { type: :string },
              question_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { activity_question: { activity_id: create(:activity, :topical, user: user).id, question_id: create(:question).id } } }

        run_test!
      end
    end
  end

  path '/api/v1/user/activity_questions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete activity questions') do
      tags 'User Activity Questions'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
