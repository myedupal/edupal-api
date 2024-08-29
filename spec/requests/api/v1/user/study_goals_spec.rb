require 'swagger_helper'

RSpec.describe 'api/v1/user/study_goals', type: :request do
  let(:curriculum) { create(:curriculum) }
  let(:user) { create(:user, selected_curriculum: curriculum) }
  let(:Authorization) { bearer_token_for(user) }
  let(:study_goal) { create(:study_goal, :with_subject, user: user, curriculum: curriculum, subject_count: 4) }
  let(:id) { study_goal.id }

  path '/api/v1/user/study_goals' do
    get('list user study goals') do
      tags 'User Study Goals'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :current_curriculum, in: :query, type: :boolean, required: false, description: 'Filter by user current curriculum'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'

      response(200, 'successful') do
        before do
          create_list(:study_goal, 3, :with_subject, subject_count: 3, user: user)
        end

        run_test!
      end
    end

    post('create user study goals') do
      tags 'User Study Goals'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          study_goal: {
            type: :object,
            properties: {
              curriculum_id: { type: :string },
              grade_a_count: { type: :integer },
              study_goal_subjects_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    subject_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { study_goal: attributes_for(:study_goal, curriculum: curriculum).merge(
            study_goal_subjects_attributes:
              [attributes_for(:study_goal_subject, curriculum: curriculum).slice(:subject_id),
               attributes_for(:study_goal_subject, curriculum: curriculum).slice(:subject_id)]
          ) }
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/study_goals/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show study goals') do
      tags 'User Study Goals'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update study goals') do
      tags 'User Study Goals'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          study_goal: {
            type: :object,
            properties: {
              curriculum_id: { type: :string },
              grade_a_count: { type: :integer },
              study_goal_subjects_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :string },
                    _destroy: { type: :boolean },
                    subject_id: { type: :string }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { study_goal: attributes_for(:study_goal).slice(:a_grade_count) }
        end

        run_test!
      end
    end

    delete('delete study goals') do
      tags 'User Study Goals'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
