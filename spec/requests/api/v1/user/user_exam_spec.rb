require 'swagger_helper'

RSpec.describe 'api/v1/user/user_exams', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:user_exam, :with_questions, created_by: user).id }

  path '/api/v1/user/user_exams' do
    get('list user exams') do
      tags 'User User Exams'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'

      response(200, 'successful') do
        before do
          create_list(:user_exam, 3, :with_questions, created_by: user)
        end

        run_test!
      end
    end

    post('create user exams') do
      tags 'User User Exams'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user_exam: {
            type: :object,
            properties: {
              title: { type: :string },
              subject_id: { type: :string },
              is_public: { type: :boolean },
              user_exam_questions_attributes: {
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
          { user_exam: attributes_for(:user_exam).slice(:title, :subject_id).merge(
            user_exam_questions_attributes: [attributes_for(:user_exam_question).slice(:question_id),
                                             attributes_for(:user_exam_question).slice(:question_id)]
          ) }
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/user_exams/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id or nanoid'

    get('show user exams') do
      tags 'User User Exams'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        let(:id) { create(:user_exam, :with_questions, is_public: true).nanoid }

        run_test!
      end

      response(403, 'forbidden') do
        let(:id) { create(:user_exam, :with_questions, is_public: false).id }

        run_test!
      end
    end

    put('update user exams') do
      tags 'User User Exams'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          user_exam: {
            type: :object,
            properties: {
              title: { type: :string },
              subject_id: { type: :string },
              is_public: { type: :boolean },
              user_exam_questions_attributes: {
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
        let(:data) { { user_exam: attributes_for(:user_exam).slice(:title) } }

        run_test!
      end
    end

    delete('delete user exams') do
      tags 'User User Exams'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
