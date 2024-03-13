require 'swagger_helper'

RSpec.describe 'api/v1/user/submission_answers', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:submission_answer, user: user).id }

  path '/api/v1/user/submission_answers' do
    get('list submission answers') do
      tags 'User Submission Answers'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :challenge_submission_id, in: :query, type: :string, required: false, description: 'Filter by challenge submission id'
      parameter name: :question_id, in: :query, type: :string, required: false, description: 'Filter by question id'

      response(200, 'successful') do
        before do
          create_list(:submission_answer, 3, challenge_submission: nil, user: user)
          create(:submission_answer, user: user)
        end

        run_test!
      end
    end

    post('create submission answers') do
      tags 'User Submission Answers'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          submission_answer: {
            type: :object,
            properties: {
              challenge_submission_id: { type: :string },
              question_id: { type: :string },
              answer: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { submission_answer: attributes_for(:submission_answer).slice(:question_id, :answer) } }

        run_test!
      end

      response(403, 'forbidden') do
        let(:data) do
          { submission_answer: attributes_for(:submission_answer, challenge_submission: create(:challenge_submission, user: user, status: 'failed')).slice(:challenge_submission_id, :question_id,
                                                                                                                                                           :answer) }
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/submission_answers/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show submission answers') do
      tags 'User Submission Answers'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update submission answers') do
      tags 'User Submission Answers'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          submission_answer: {
            type: :object,
            properties: {
              answer: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:id) { create(:submission_answer, user: user).id }
        let(:data) { { submission_answer: attributes_for(:submission_answer).slice(:answer) } }

        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:submission_answer, user: user, challenge_submission: nil).id }
        let(:data) { { submission_answer: attributes_for(:submission_answer).slice(:answer) } }

        run_test!
      end
    end

    delete('delete submission answers') do
      tags 'User Submission Answers'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:submission_answer, user: user, challenge_submission: nil).id }
        let(:data) { { submission_answer: attributes_for(:submission_answer).slice(:answer) } }

        run_test!
      end
    end
  end
end
