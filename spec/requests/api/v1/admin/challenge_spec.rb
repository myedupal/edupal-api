require 'swagger_helper'

RSpec.describe 'api/v1/admin/challenges', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:challenge, :with_questions).id }

  path '/api/v1/admin/challenges' do
    get('list challenges') do
      tags 'Admin Challenges'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by title'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'

      response(200, 'successful') do
        before do
          create_list(:challenge, 3, :with_questions)
        end

        run_test!
      end
    end

    post('create challenges') do
      tags 'Admin Challenges'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          challenge: {
            type: :object,
            properties: {
              title: { type: :string },
              challenge_type: { type: :string, enum: Challenge.challenge_types.keys },
              start_at: { type: :string },
              end_at: { type: :string },
              reward_points: { type: :integer },
              reward_type: { type: :string, enum: Challenge.reward_types.keys },
              penalty_seconds: { type: :integer },
              subject_id: { type: :string },
              challenge_questions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    question_id: { type: :string },
                    score: { type: :integer },
                    display_order: { type: :integer }
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
            challenge: attributes_for(:challenge).merge(
              challenge_questions_attributes: [
                attributes_for(:challenge_question).except(:challenge_id),
                attributes_for(:challenge_question).except(:challenge_id)
              ]
            )
          }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/challenges/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show challenges') do
      tags 'Admin Challenges'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update challenges') do
      tags 'Admin Challenges'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          challenge: {
            type: :object,
            properties: {
              title: { type: :string },
              challenge_type: { type: :string, enum: Challenge.challenge_types.keys },
              start_at: { type: :string },
              end_at: { type: :string },
              reward_points: { type: :integer },
              reward_type: { type: :string, enum: Challenge.reward_types.keys },
              penalty_seconds: { type: :integer },
              subject_id: { type: :string },
              challenge_questions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    question_id: { type: :string },
                    score: { type: :integer },
                    display_order: { type: :integer }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:id) { create(:challenge, :with_questions, start_at: 1.day.from_now).id }
        let(:data) { { challenge: attributes_for(:challenge) } }

        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:challenge, :with_questions, start_at: 1.day.ago).id }
        let(:data) { { challenge: attributes_for(:challenge) } }

        run_test!
      end
    end

    delete('delete challenges') do
      tags 'Admin Challenges'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        let(:id) { create(:challenge, :with_questions).id }

        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:challenge, :with_questions, start_at: 1.day.ago).id }

        before do
          create(:challenge_submission, challenge_id: id)
        end

        run_test!
      end
    end
  end
end
