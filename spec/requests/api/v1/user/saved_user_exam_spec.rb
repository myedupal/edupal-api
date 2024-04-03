require 'swagger_helper'

RSpec.describe 'api/v1/user/saved_user_exams', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:saved_user_exam, user: user, user_exam: create(:user_exam, :with_questions)).id }

  path '/api/v1/user/saved_user_exams' do
    get('list saved user exams') do
      tags 'User Saved User Exams'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'

      response(200, 'successful') do
        before do
          3.times { create(:saved_user_exam, user: user, user_exam: create(:user_exam, :with_questions)) }
        end

        run_test!
      end
    end

    post('create saved user exams') do
      tags 'User Saved User Exams'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          saved_user_exam: {
            type: :object,
            properties: {
              user_exam_id: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { saved_user_exam: attributes_for(:saved_user_exam).slice(:user_exam_id) } }

        run_test!
      end
    end
  end

  path '/api/v1/user/saved_user_exams/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    delete('delete saved user exams') do
      tags 'User Saved User Exams'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
