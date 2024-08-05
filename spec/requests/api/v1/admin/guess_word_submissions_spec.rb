require 'swagger_helper'

RSpec.describe "api/v1/admin/guess_word_submissions", type: :request do
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:guess_word_submission) { create(:guess_word_submission) }
  let(:id) { guess_word_submission.id }

  path '/api/v1/admin/guess_word_submissions' do
    get('list guess word submissions') do
      tags 'Admin Guess Word Submissions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'
      parameter name: :guess_word_id, in: :query, type: :string, required: false, description: 'Filter by guess word id'
      parameter name: :user_id, in: :query, type: :string, required: false, description: 'Filter by subject id'

      response(200, 'successful') do
        before do
          create_list(:guess_word_submission, 2)
          create(:guess_word_submission).tap do |guess_word_submission|
            create_list(:guess_word_submission_guess, 3, guess_word_submission: guess_word_submission)
          end
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/guess_word_submissions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show guess word submissions') do
      tags 'Admin Guess Word Submissions'
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

end
