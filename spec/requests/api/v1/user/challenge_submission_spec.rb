require 'swagger_helper'

RSpec.describe 'api/v1/user/challenge_submissions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:challenge) { create(:challenge, :published, :daily, start_at: Time.current) }
  let(:question) { create(:question, :mcq_with_answer) }
  let!(:challenge_question) { create(:challenge_question, challenge: challenge, question: question, score: 10) }
  let(:id) { create(:challenge_submission, user: user, challenge: challenge).id }

  path '/api/v1/user/challenge_submissions' do
    get('list challenge submissions') do
      tags 'User Challenge Submissions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :challenge_id, in: :query, type: :string, required: false, description: 'Filter by challenge id'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'
      parameter name: :challenge_type, in: :query, type: :string, required: false, description: 'Filter by challenge type'

      response(200, 'successful') do
        before do
          3.times do
            challenge = create(:challenge, :published, :daily, start_at: Time.current)
            question = create(:question, :mcq_with_answer)
            create(:challenge_question, challenge: challenge, question: question, score: 10)
            submission = create(:challenge_submission, user: user, challenge: challenge)
            create(:submission_answer, challenge_submission: submission, question: question)
            submission.submit!
          end
        end

        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['challenge_submissions'].size).to eq(3)
        end
      end
    end

    post('create challenge submissions') do
      tags 'User Challenge Submissions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          challenge_submission: {
            type: :object,
            properties: {
              challenge_id: { type: :string },
              submission_answers_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    question_id: { type: :string },
                    answer: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          {
            challenge_submission: {
              challenge_id: challenge.id,
              submission_answers_attributes: [{ question_id: question.id, answer: question.answers.first.text }]
            }
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/challenge_submissions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show challenge submissions') do
      tags 'User Challenge Submissions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update challenge submissions') do
      tags 'User Challenge Submissions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          challenge_submission: {
            type: :object,
            properties: {
              challenge_id: { type: :string },
              submission_answers_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    question_id: { type: :string },
                    answer: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      let(:data) { { challenge_submission: { submission_answers_attributes: [{ question_id: question.id, answer: question.answers.first.text }] } } }

      response(200, 'successful', save_request_example: :data) do
        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:challenge_submission, user: user, challenge: challenge, status: 'failed').id }

        run_test!
      end
    end

    delete('delete challenge submissions') do
      tags 'User Challenge Submissions'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:challenge_submission, user: user, challenge: challenge, status: 'failed').id }

        run_test!
      end
    end
  end

  path '/api/v1/user/challenge_submissions/{id}/submit' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    put('submit challenge submissions') do
      tags 'User Challenge Submissions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      before do
        create(:submission_answer, challenge_submission_id: id, question: question)
      end

      response(200, 'successful', save_request_example: :data) do
        run_test!
      end
    end
  end

  path '/api/v1/user/challenge_submissions/direct_submit' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('direct submit challenge submissions') do
      tags 'User Challenge Submissions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      description "Use this API to directly submit a challenge and have the answers evaluated."

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          challenge_submission: {
            type: :object,
            properties: {
              challenge_id: { type: :string },
              submission_answers_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    question_id: { type: :string },
                    answer: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          {
            challenge_submission: {
              challenge_id: challenge.id,
              submission_answers_attributes: [{ question_id: question.id, answer: question.answers.first.text }]
            }
          }
        end

        run_test!
      end
    end
  end
end