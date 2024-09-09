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
      parameter name: :date_by, in: :query, type: :string, required: false, description: 'Filter date by field'
      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter date range start'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'Filter date range end'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by answer'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :guess_word_pool_id, in: :query, type: :string, required: false, description: 'Filter by guess word pool id, empty to filter for no pool id'
      parameter name: :system_guess_word_pool, in: :query, type: :string, required: false, description: 'Filter for system guess word pool'
      parameter name: :ongoing, in: :query, type: :string, required: false, description: 'Filter by ongoing'
      parameter name: :ended, in: :query, type: :string, required: false, description: 'Filter by ended'
      parameter name: :only_submitted_by, in: :query, type: :string, required: false, description: 'Filter for submitted by user'
      parameter name: :only_unsubmitted_by, in: :query, type: :string, required: false, description: 'Filter for unsubmitted by user'
      parameter name: :only_completed_by, in: :query, type: :string, required: false, description: 'Filter for completed by user'
      parameter name: :only_available_for, in: :query, type: :string, required: false, description: 'Filter for incomplete or unsubmitted for user'
      parameter name: :with_reports, in: :query, type: :string, required: false, description: 'Include reporting'

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
          create(:guess_word, guess_word_pool: create(:guess_word_pool))
        end

        run_test!
      end

      context 'with include_reporting' do
        let(:with_reports) { true }
        let!(:guess_word) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, :with_guesses, guess_word: guess_word)
            create_list(:guess_word_submission, 2, :success, :with_guesses, guess_count: 5, guess_word: guess_word)
            create_list(:guess_word_submission, 1, :expired, :with_guesses, guess_word: guess_word)
            create_list(:guess_word_submission, 1, :failed, :with_guesses, guess_word: guess_word)
          end
        end
        let!(:another_guess_word) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, :success, guess_word: guess_word)
            create(:guess_word_submission, :success, guess_word: guess_word)
            create(:guess_word_submission, :failed, guess_word: guess_word)
          end
        end

        it 'includes reporting' do
          get api_v1_admin_guess_words_path, params: { with_reports: with_reports }, headers: { Authorization: bearer_token_for(user) }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)

          report = data['guess_words'].find { |gw| gw['id'] == guess_word.id }
          expect(report).to be_present
          expect(report['guess_word_submissions_count']).to eq(5)
          expect(report['completed_count']).to eq(4)
          expect(report['avg_guesses_count']).to be_present
          expect(report['in_progress_count']).to eq(1)
          expect(report['success_count']).to eq(2)
          expect(report['success_count']).to eq(2)
          expect(report['expired_count']).to eq(1)
          expect(report['failed_count']).to eq(1)

          another_report = data['guess_words'].find { |gw| gw['id'] == another_guess_word.id }
          expect(another_report).to be_present
          expect(another_report['guess_word_submissions_count']).to eq(3)
          expect(another_report['completed_count']).to eq(3)
          expect(another_report['success_count']).to eq(2)
          expect(another_report['failed_count']).to eq(1)
        end
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

  path '/api/v1/admin/guess_words/export_csv' do
    get('export guess words') do
      tags 'Admin Guess Words'
      produces 'text/csv'
      security [{ bearerAuth: nil }]

      parameter name: :date_by, in: :query, type: :string, required: false, description: 'Filter date by field'
      parameter name: :from_date, in: :query, type: :string, required: false, description: 'Filter date range start'
      parameter name: :to_date, in: :query, type: :string, required: false, description: 'Filter date range end'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by answer'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :guess_word_pool_id, in: :query, type: :string, required: false, description: 'Filter by guess word pool id, empty to filter for no pool id'
      parameter name: :system_guess_word_pool, in: :query, type: :string, required: false, description: 'Filter for system guess word pool'
      parameter name: :ongoing, in: :query, type: :string, required: false, description: 'Filter by ongoing'
      parameter name: :ended, in: :query, type: :string, required: false, description: 'Filter by ended'
      parameter name: :only_submitted_by, in: :query, type: :string, required: false, description: 'Filter for submitted by user'
      parameter name: :only_unsubmitted_by, in: :query, type: :string, required: false, description: 'Filter for unsubmitted by user'
      parameter name: :only_completed_by, in: :query, type: :string, required: false, description: 'Filter for completed by user'
      parameter name: :only_available_for, in: :query, type: :string, required: false, description: 'Filter for incomplete or unsubmitted for user'

      response(200, 'successful') do
        let!(:guess_word) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, :with_guesses, guess_word: guess_word)
            create_list(:guess_word_submission, 2, :success, :with_guesses, guess_count: 5, guess_word: guess_word)
            create_list(:guess_word_submission, 1, :expired, :with_guesses, guess_word: guess_word)
            create_list(:guess_word_submission, 1, :failed, :with_guesses, guess_word: guess_word)
          end
        end
        let!(:another_guess_word) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, :success, :with_guesses, guess_word: guess_word)
            create(:guess_word_submission, :success, :with_guesses, guess_word: guess_word)
            create(:guess_word_submission, :failed, :with_guesses, guess_word: guess_word)
          end
        end

        after do |example|
          example.metadata[:response][:content] = { 'text/csv': { examples: { test_example: { value: response.body } } } }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/guess_words/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :with_reports, in: :query, type: :string, required: false, description: 'Include reporting'

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
