require 'swagger_helper'

RSpec.describe "api/v1/admin/guess_words", type: :request do
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:guess_word) { create(:guess_word) }
  let(:id) { guess_word.id }

  path '/api/v1/admin/guess_words' do
    get('list guess words') do
      tags 'Admin Guess Words'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by answer'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :ongoing, in: :query, type: :string, required: false, description: 'Filter by ongoing'
      parameter name: :ended, in: :query, type: :string, required: false, description: 'Filter by ended'
      parameter name: :only_submitted_by, in: :query, type: :string, required: false, description: 'Filter for submitted by user'
      parameter name: :only_unsubmitted_by, in: :query, type: :string, required: false, description: 'Filter for unsubmitted by user'
      parameter name: :only_completed_by, in: :query, type: :string, required: false, description: 'Filter for completed by user'
      parameter name: :only_available_for, in: :query, type: :string, required: false, description: 'Filter for incomplete or unsubmitted for user'

      response(200, 'successful') do
        before do
          create_list(:guess_word, 2).each do |guess_word|
            create_list(:guess_word_submission, Faker::Number.between(from: 1, to: 3), guess_word: guess_word)
          end

          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, guess_word: guess_word).tap do |guess_word_submission|
              create(:guess_word_submission_guess, guess_word_submission: guess_word_submission)
            end
          end
        end

        run_test!
      end
    end

    post('create guess words') do
      tags 'Admin Guess Words'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess_word: {
            type: :object,
            properties: {
              guess_word_id: { type: :string },
              answer: { type: :string },
              description: { type: :string },
              attempts: { type: :string },
              reward_points: { type: :integer },
              start_at: { type: :string },
              end_at: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { guess_word: attributes_for(:guess_word) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/guess_words/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show guess words') do
      tags 'Admin Guess Words'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      before do
        create(:guess_word_submission, guess_word: guess_word).tap do |guess_word_submission|
          create(:guess_word_submission_guess, guess_word_submission: guess_word_submission)
        end
      end

      response(200, 'successful') do
        run_test!
      end
    end

    put('update guess words') do
      tags 'Admin Guess Words'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess_word: {
            type: :object,
            properties: {
              subject_id: { type: :string },
              answer: { type: :string },
              description: { type: :string },
              attempts: { type: :string },
              reward_points: { type: :integer },
              start_at: { type: :string },
              end_at: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { guess_word: attributes_for(:guess_word) } }

        run_test!
      end
    end

    delete('delete guess words') do
      tags 'Admin Guess Words'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end

end
