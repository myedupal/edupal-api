require 'swagger_helper'

RSpec.describe 'api/v1/user/activities', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:activity, :topical, user: user).id }

  path '/api/v1/user/activities' do
    get('list activities') do
      tags 'User Activities'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by Subject id'
      parameter name: :exam_id, in: :query, type: :string, required: false, description: 'Filter by Exam id'
      parameter name: :activity_type, in: :query, schema: { type: :string, enum: Activity.activity_types.keys }, required: false, description: 'Filter by Activity type'

      response(200, 'successful') do
        before do
          create_list(:activity, 2, :topical, user: user)
          create_list(:activity, 2, :yearly, user: user)
        end

        run_test!
      end
    end

    post('create activities') do
      tags 'User Activities'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          activity: {
            type: :object,
            properties: {
              title: { type: :string },
              recorded_time: { type: :integer },
              activity_type: { type: :string, enum: Activity.activity_types.keys },
              subject_id: { type: :string },
              exam_id: { type: :string },
              topic_ids: { type: :array, items: { type: :string } },
              paper_ids: { type: :array, items: { type: :string } },
              metadata: {
                type: :object,
                properties: {
                  sort_by: { type: :string },
                  sort_order: { type: :string },
                  page: { type: :string },
                  items: { type: :string },
                  years: { type: :array, items: { type: :string } },
                  seasons: { type: :array, items: { type: :string } },
                  zones: { type: :array, items: { type: :string } },
                  levels: { type: :array, items: { type: :string } },
                  question_type: { type: :string },
                  numbers: { type: :array, items: { type: :string } },
                  last_question_id: { type: :string },
                  last_position: { type: :string }
                }
              }
            }
          }
        }
      }

      # explicitly disable bullet for this test
      # because it will raise N+1 query due to the use of paper_ids and topic_ids
      before do
        Bullet.raise = false
      end

      after do
        Bullet.raise = true
      end

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { activity: attributes_for(:activity, :topical)
            .merge(topic_ids: create_list(:topic, 2).map(&:id),
                   paper_ids: create_list(:paper, 2).map(&:id)) }
        end

        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['activity']['activity_type']).to eq('topical')
          expect(parsed_response['activity']['topic_ids'].size).to eq(2)
          expect(parsed_response['activity']['paper_ids'].size).to eq(2)
        end
      end
    end
  end

  path '/api/v1/user/activities/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show activities') do
      tags 'User Activities'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update activities') do
      tags 'User Activities'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          activity: {
            type: :object,
            properties: {
              title: { type: :string },
              recorded_time: { type: :integer },
              metadata: {
                type: :object,
                properties: {
                  sort_by: { type: :string },
                  sort_order: { type: :string },
                  page: { type: :string },
                  items: { type: :string },
                  last_question_id: { type: :string },
                  last_position: { type: :string }
                }
              }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) do
          { activity: { metadata: { sort_by: 'question_number', sort_order: 'asc' } } }
        end

        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['activity']['metadata']['sort_by']).to eq('question_number')
          expect(parsed_response['activity']['metadata']['sort_order']).to eq('asc')
        end
      end
    end

    delete('delete activities') do
      tags 'User Activities'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
