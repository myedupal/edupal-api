require 'swagger_helper'

RSpec.describe "api/v1/admin/guess_word_dictionaries", type: :request do
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:guess_word_dictionary) { create(:guess_word_dictionary) }
  let(:id) { guess_word_dictionary.id }

  path '/api/v1/admin/guess_word_dictionaries' do
    get('list guess word dictionaries') do
      tags 'Admin Guess Word Dictionaries'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by answer'

      response(200, 'successful') do
        before do
          create_list(:guess_word_dictionary, 3)
        end

        run_test!
      end
    end

    post('create guess word dictionaries') do
      tags 'Admin Guess Word Dictionaries'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess_word_dictionary: {
            type: :object,
            properties: {
              word: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { guess_word_dictionary: attributes_for(:guess_word_dictionary) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/guess_word_dictionaries/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show guess word dictionaries') do
      tags 'Admin Guess Word Dictionaries'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update guess word dictionaries') do
      tags 'Admin Guess Word Dictionaries'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess_word: {
            type: :object,
            properties: {
              word: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { guess_word_dictionary: attributes_for(:guess_word_dictionary) } }

        run_test!
      end
    end

    delete('delete guess word dictionaries') do
      tags 'Admin Guess Word Dictionaries'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
