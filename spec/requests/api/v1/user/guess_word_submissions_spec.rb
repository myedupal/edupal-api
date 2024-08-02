require 'swagger_helper'

RSpec.describe "api/v1/user/guess_word_submissions", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:guess_word) { create(:guess_word) }
  let(:guess_word_submission) { create(:guess_word_submission, user: user, guess_word: guess_word) }
  let(:id) { guess_word_submission.id }

  path '/api/v1/user/guess_word_submissions' do
    get('list guess word submissions') do
      tags 'User Guess Word Submissions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'
      parameter name: :guess_word_id, in: :query, type: :string, required: false, description: 'Filter by guess word id'

      response(200, 'successful') do
        before do
          create(:guess_word_submission)

          create_list(:guess_word_submission, 2, user: user)

          create(:guess_word_submission, user: user).tap do |guess_word_submission|
            create(:guess_word_submission_guess, guess_word_submission: guess_word_submission)
          end

          create(:guess_word_submission, user: user, status: :failed, completed_at: Time.now).tap do |guess_word_submission|
            create_list(:guess_word_submission_guess, 3, guess_word_submission: guess_word_submission)
          end
        end

        run_test! do |response|

          data = JSON.parse(response.body)

          data['guess_word_submissions'].each do |submission|
            expect(submission['user_id']).to eq user.id
          end

          data['guess_word_submissions'].find { |sub| sub['completed_at'].present? }.tap do |submission|
            expect(submission['guesses'].count).to eq 3
            expect(submission['guess_word_answer']).to be_present
            expect(submission['guess_word']['answer']).to_not be_present
          end
        end
      end

      post('create guess word submissions') do
        tags 'User Guess Word Submissions'
        produces 'application/json'
        consumes 'application/json'
        security [{ bearerAuth: nil }]

        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            guess_word_submission: {
              type: :object,
              properties: {
                guess_word_id: { type: :string }
              }
            }
          }
        }

        response(200, 'successful', save_request_example: :data) do
          let(:guess_word) { create(:guess_word) }
          let(:data) { { guess_word: { guess_word_id: guess_word.id } } }

          run_test!
        end
      end
    end
  end

  path '/api/v1/user/guess_word_submissions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show guess word submissions') do
      tags 'User Guess Word Submissions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      before do
        create_list(:guess_word_submission_guess, 4, guess_word_submission: guess_word_submission)
      end

      response(200, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/user/guess_word_submissions/{id}/guess' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    let(:guess_word) { create(:guess_word, answer: Faker::Lorem.characters(number: 7)) }
    let(:testing_words) { [] }
    before do
      testing_words.each { |word| GuessWordDictionary.create(word: word) }
    end

    post('submit guess guess word submissions') do
      tags 'User Guess Word Submissions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:testing_words) { [word] }
        let(:word) { Faker::Lorem.characters(number: 7) }
        let(:data) { { guess: word } }

        run_test!
      end
    end
  end

  path '/api/v1/user/guess_words/{guess_word_id}/guess_word_submissions/guess' do
    parameter name: 'guess_word_id', in: :path, type: :string, description: 'id'
    let(:character_length) { 7 }
    let(:guess_word) { create(:guess_word, answer: Faker::Lorem.characters(number: character_length), attempts: 5) }
    let(:guess_word_id) { guess_word.id }
    let(:testing_words) { [] }
    before do
      testing_words.each { |word| GuessWordDictionary.create(word: word) }
    end

    post('submit guess guess word submissions') do
      tags 'User Guess Word Submissions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess: { type: :string }
        }
      }

      response(200, 'successful') do
        let(:testing_words) { [word] }
        let(:word) { Faker::Lorem.characters(number: character_length) }
        let(:data) { { guess: word } }

        before do
          create(:guess_word)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['guess_word_submission']['guess_word_id']).to eq guess_word.id
          expect(guess_word.guess_word_submissions.where(user: user).count).to eq 1
        end
      end
    end

    context 'existing guess word submission' do
      let(:guess_word_submission) { create(:guess_word_submission, user: user, guess_word: guess_word) }
      let(:submission_count) { 2 }
      let(:testing_words) { [word] }
      let(:word) { Faker::Lorem.characters(number: character_length) }

      before do
        create_list(:guess_word_submission_guess, submission_count, guess_word_submission: guess_word_submission)
      end

      context 'with guess' do
        it 'add guesses onto existing submission' do
          post "/api/v1/user/guess_words/#{guess_word_id}/guess_word_submissions/guess", params: { guess: word }, headers: { Authorization: bearer_token_for(user) }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data['guess_word_submission']['guesses'].count).to eq 3
          expect(data['guess_word_submission']['guesses'][-1]['result'].count).to eq character_length
          expect(guess_word.reload.guess_word_submissions.count).to eq 1
        end
      end

      context 'with correct guess' do
        let(:word) { guess_word.answer }

        it 'change status to success' do
          post "/api/v1/user/guess_words/#{guess_word_id}/guess_word_submissions/guess", params: { guess: word }, headers: { Authorization: bearer_token_for(user) }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data['guess_word_submission']['guesses'].count).to eq 3
          expect(data['guess_word_submission']['status']).to eq 'success'
          expect(data['guess_word_submission']['completed_at']).to be_present
          expect(data['guess_word_submission']['guess_word_answer']).to be_present
        end
      end

      context 'with over guess count' do
        let(:submission_count) { 4 }

        it 'change status to success' do
          post "/api/v1/user/guess_words/#{guess_word_id}/guess_word_submissions/guess", params: { guess: word }, headers: { Authorization: bearer_token_for(user) }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)
          expect(data['guess_word_submission']['guesses'].count).to eq 5
          expect(data['guess_word_submission']['status']).to eq 'failed'
          expect(data['guess_word_submission']['completed_at']).to be_present
          expect(data['guess_word_submission']['guess_word_answer']).to be_present
        end
      end

      context 'incorrect word length' do
        let(:testing_words) { [word] }
        let(:word) { Faker::Lorem.characters(number: character_length + 1) }

        it 'does not add guesses onto existing submission' do
          post "/api/v1/user/guess_words/#{guess_word_id}/guess_word_submissions/guess", params: { guess: word }, headers: { Authorization: bearer_token_for(user) }

          expect(response).to have_http_status(:unprocessable_entity)
          data = JSON.parse(response.body)
          expect(data['errors'].count).to eq 1
          expect(data['errors'][0]['message']).to match(/is not the same length/)
        end
      end
    end
  end
end
