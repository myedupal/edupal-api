require 'swagger_helper'

RSpec.describe "api/v1/user/guess_words", type: :request do
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:guess_word) { create(:guess_word) }
  let(:id) { guess_word.id }

  path '/api/v1/user/guess_words' do
    get('list guess word') do
      tags 'User Guess Word'
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
      parameter name: :submitted, in: :query, type: :string, required: false, description: 'Filter by guess word with user submission'
      parameter name: :unsubmitted, in: :query, type: :string, required: false, description: 'Filter by guess word without user submission'
      parameter name: :completed, in: :query, type: :string, required: false, description: 'Filter by guess word with completed user submission'
      parameter name: :incomplete, in: :query, type: :string, required: false, description: 'Filter by guess word with incomplete user submission'
      parameter name: :available, in: :query, type: :string, required: false, description: 'Filter by guess word that are incomplete or unsubmitted by user submission'

      response(200, 'successful') do
        let!(:guess_word) { create(:guess_word) }
        let!(:guess_word_with_others_submission) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, guess_word: guess_word)
          end
        end
        let!(:in_progress_guess_word) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, guess_word: guess_word, user: user).tap do |guess_word_submission|
              create_list(:guess_word_submission_guess, 4, guess_word_submission: guess_word_submission)
            end
          end
        end
        let!(:completed_guess_word) do
          create(:guess_word).tap do |guess_word|
            create(:guess_word_submission, guess_word: guess_word, status: :success, completed_at: Time.now, user: user)
            create(:guess_word_submission, guess_word: guess_word, status: :success, completed_at: Time.now)
          end
        end

        before do
          create(:guess_word, start_at: 1.day.from_now, end_at: 3.days.from_now)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['guess_words'].map { |guess_word| guess_word['id'] })
            .to match_array([guess_word, guess_word_with_others_submission, in_progress_guess_word, completed_guess_word].map(&:id))

          data['guess_words'].find { |guess_word| guess_word['id'] == completed_guess_word.id }.tap do |guess_word|
            expect(guess_word['answer']).to be_present
            expect(guess_word['answer_length']).to be_present
            expect(guess_word['guess_word_submissions']).to_not be_present
          end
        end
      end
    end
  end

  path '/api/v1/user/guess_words/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show guess word') do
      tags 'User Guess Word'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :include_submissions, in: :query, type: :string, required: false, description: 'Include user submission in guess_words'

      response(200, 'successful') do
        before do
          create(:guess_word_submission, guess_word: guess_word, user: user).tap do |guess_word_submission|
            create_list(:guess_word_submission_guess, 3, guess_word_submission: guess_word_submission)
          end
          create(:guess_word_submission, guess_word: guess_word)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['guess_word']['answer']).to eq(nil)
          expect(data['guess_word']['answer_length']).to be_present
          expect(data['guess_word']['guess_word_submissions']).to_not be_present
        end
      end
    end
  end
end
