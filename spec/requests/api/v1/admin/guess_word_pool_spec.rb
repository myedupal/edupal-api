require 'swagger_helper'

RSpec.describe 'api/v1/admin/guess_word_pools', type: :request do
  let(:admin) { create(:admin) }
  let(:Authorization) { bearer_token_for(admin) }
  let(:guess_word_pool) { create(:guess_word_pool, :with_questions, question_count: 3) }
  let(:id) { guess_word_pool.id }

  path '/api/v1/admin/guess_word_pools' do
    get('list guess word pools') do
      tags 'Admin Guess Word Pools'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :user_id, in: :query, type: :string, required: false, description: 'Filter by user id, empty for no user id'
      parameter name: :published, in: :query, type: :boolean, required: false, description: 'Filter by published status'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Query by title'

      response(200, 'successful') do
        before do
          create_list(:guess_word_pool, 3, :with_questions, question_count: 1)
        end

        run_test!
      end
    end

    post('create guess word pools') do
      tags 'Admin Guess Word Pools'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess_word_pool: {
            type: :object,
            properties: {
              subject_id: { type: :string },
              title: { type: :string },
              description: { type: :string },
              published: { type: :boolean },
              guess_word_questions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    word: { type: :string },
                    description: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { guess_word_pool: attributes_for(:guess_word_pool).slice(:title, :description, :subject_id).merge(
            guess_word_questions_attributes:
              [
                attributes_for(:guess_word_question).slice(:word, :description),
                attributes_for(:guess_word_question).slice(:word, :description)
              ]
          ) }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['guess_word_pool']['guess_word_questions'].size).to eq 2
        end
      end
    end
  end

  path '/api/v1/admin/guess_word_pools/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show guess word pools') do
      tags 'Admin Guess Word Pools'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['guess_word_pool']['guess_word_questions'].size).to eq 3
        end
      end
    end

    put('update guess word pools') do
      tags 'Admin Guess Word Pools'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          guess_word_pool: {
            type: :object,
            properties: {
              subject_id: { type: :string },
              title: { type: :string },
              description: { type: :string },
              published: { type: :boolean },
              guess_word_questions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    word: { type: :string },
                    description: { type: :string },
                    _destroy: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { guess_word_pool: attributes_for(:guess_word_pool).slice(:title, :description) } }

        run_test!
      end
    end

    delete('delete guess word pools') do
      tags 'Admin Guess Word Pools'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end

  path '/api/v1/admin/guess_word_pools/{id}/import' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    post('import guess word pools') do
      tags 'Admin Guess Word Pools'
      produces 'application/json'
      consumes 'multipart/form-data'
      security [{ bearerAuth: nil }]

      parameter name: :file, in: :formData, type: :file, required: true, description: 'CSV file with "word" and "description" as header'

      let(:guess_word_pool) { create(:guess_word_pool) }
      let(:file) { fixture_file_upload(file_fixture('guess_word_pool.csv')) }

      response(200, 'successful', save_request_example: :data) do
        run_test! do |response|
          data = JSON.parse(response.body)

          expect(data['meta']['read']).to eq 7
          expect(data['meta']['imported']).to eq 5
          expect(data['guess_word_pool']['guess_word_questions'].count).to eq 5
          guess_word_pool.reload
          expect(guess_word_pool.guess_word_questions.count).to eq 5
          expect(guess_word_pool.guess_word_questions.all.map { |r| r.attributes.slice('word', 'description').with_indifferent_access })
            .to contain_exactly({ word: 'word1', description: 'aliquam' },
                                { word: 'word2', description: 'mattis' },
                                { word: 'word3', description: 'id venenatis' },
                                { word: 'word4', description: 'Nullam blandit' },
                                { word: 'word5', description: '' })
          expect(guess_word_pool.guess_word_questions.all.map(&:word)).to contain_exactly('word1', 'word2', 'word3', 'word4', 'word5')
        end
      end

      context 'with existing words' do
        before do
          create(:guess_word_question, guess_word_pool: guess_word_pool, word: 'word1')
          create(:guess_word_question, guess_word_pool: guess_word_pool, word: 'word2')
        end

        it 'imports new words' do
          post import_api_v1_admin_guess_word_pool_path(id: id), params: { file: file }, headers: { Authorization: bearer_token_for(admin) }

          expect(response).to have_http_status(:ok)
          data = JSON.parse(response.body)

          expect(data['meta']['read']).to eq 7
          expect(data['meta']['imported']).to eq 5
          guess_word_pool.reload
          expect(guess_word_pool.guess_word_questions.count).to eq 5
          expect(guess_word_pool.guess_word_questions.all.map { |r| r.attributes.slice('word', 'description').with_indifferent_access })
            .to contain_exactly({ word: 'word1', description: 'aliquam' },
                                { word: 'word2', description: 'mattis' },
                                { word: 'word3', description: 'id venenatis' },
                                { word: 'word4', description: 'Nullam blandit' },
                                { word: 'word5', description: '' })
          expect(guess_word_pool.guess_word_questions.all.map(&:word)).to contain_exactly('word1', 'word2', 'word3', 'word4', 'word5')
        end
      end
    end
  end
end
