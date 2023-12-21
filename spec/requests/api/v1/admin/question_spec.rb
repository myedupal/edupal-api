require 'swagger_helper'

RSpec.describe 'api/v1/admin/questions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:question).id }

  path '/api/v1/admin/questions' do
    get('list questions') do
      tags 'Admin Questions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :paper_id, in: :query, type: :string, required: false, description: 'Filter by paper id'
      parameter name: :topic_id, in: :query, type: :string, required: false, description: 'Filter by topic id'
      parameter name: :exam_id, in: :query, type: :string, required: false, description: 'Filter by exam id'
      parameter name: :number, in: :query, type: :string, required: false, description: 'Filter by number'
      parameter name: :question_type, in: :query, type: :string, required: false, description: 'Filter by question type'

      response(200, 'successful') do
        before do
          create_list(:question, 10)
        end

        run_test!
      end
    end

    post('create questions') do
      tags 'Admin Questions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          question: {
            type: :object,
            properties: {
              exam_id: { type: :string },
              number: { type: :string },
              question_type: { type: :string, enum: Question.question_types.keys },
              text: { type: :string },
              question_images_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    image: { type: :string },
                    display_order: { type: :integer }
                  }
                }
              },
              question_topics_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    topic_id: { type: :string }
                  }
                }
              },
              answers_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    text: { type: :string },
                    image: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { question: attributes_for(:question).merge(
            question_images_attributes: [attributes_for(:question_image)],
            question_topics_attributes: [attributes_for(:question_topic)],
            answers_attributes: [attributes_for(:answer)]
          ) }
        end

        run_test!
      end
    end
  end

  path '/api/v1/admin/questions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show questions') do
      tags 'Admin Questions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update questions') do
      tags 'Admin Questions'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          question: {
            type: :object,
            properties: {
              exam_id: { type: :string },
              number: { type: :string },
              question_type: { type: :string, enum: Question.question_types.keys },
              text: { type: :string },
              question_images_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    image: { type: :string },
                    display_order: { type: :integer }
                  }
                }
              },
              question_topics_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    topic_id: { type: :string }
                  }
                }
              },
              answers_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    text: { type: :string },
                    image: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { question: attributes_for(:question) } }

        run_test!
      end
    end

    delete('delete questions') do
      tags 'Admin Questions'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
