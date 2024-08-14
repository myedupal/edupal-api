require 'swagger_helper'

RSpec.describe 'api/v1/user/user_collections', type: :request do
  let(:curriculum) { create(:curriculum) }
  let(:user) { create(:user, selected_curriculum_id: curriculum.id) }
  let(:Authorization) { bearer_token_for(user) }
  let(:user_collection) { create(:user_collection, :with_questions, user: user, curriculum: curriculum, questions_count: 5) }
  let(:id) { user_collection.id }

  path '/api/v1/user/user_collections' do
    get('list user collections') do
      tags 'User User Collection'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :current_curriculum, in: :query, type: :boolean, required: false, description: 'Filter by user current curriculum'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :collection_type, in: :query, type: :string, required: false, description: 'Filter by collection type'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Query by title'

      response(200, 'successful') do
        let(:current_curriculum) { true }

        before do
          create_list(:user_collection, 3, :with_questions, questions_count: 1, user: user, curriculum: curriculum)
        end
        run_test!
      end
    end

    post('create user collections') do
      tags 'User User Collections'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user_collection: {
            type: :object,
            properties: {
              curriculum_id: { type: :string },
              collection_type: { type: :string },
              title: { type: :string },
              description: { type: :string },
              user_collection_questions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    question_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { user_collection: attributes_for(:user_collection).slice(:title, :collection_type, :description).merge(
            curriculum_id: curriculum.id,
            user_collection_questions_attributes:
              [attributes_for(:user_collection_question, curriculum: curriculum).slice(:question_id),
               attributes_for(:user_collection_question, curriculum: curriculum).slice(:question_id)]
          ) }
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/user_collections/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show user collections') do
      tags 'User User Collections'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update user collections') do
      tags 'User User Collections'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user_collection: {
            type: :object,
            properties: {
              curriculum_id: { type: :string },
              collection_type: { type: :string },
              title: { type: :string },
              description: { type: :string },
              user_collection_questions_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    question_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { user_collection: attributes_for(:user_collection).slice(:title, :description) } }

        run_test!
      end
    end

    delete('delete user collections') do
      tags 'User User Collections'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
