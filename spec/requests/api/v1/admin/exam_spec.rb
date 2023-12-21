require 'swagger_helper'

RSpec.describe 'api/v1/admin/exams', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:admin) }
  let(:Authorization) { bearer_token_for(user) }
  let(:id) { create(:exam).id }

  path '/api/v1/admin/exams' do
    get('list exams') do
      tags 'Admin Exams'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :paper_id, in: :query, type: :string, required: false, description: 'Filter by paper id'
      parameter name: :year, in: :query, type: :string, required: false, description: 'Filter by year'
      parameter name: :season, in: :query, type: :string, required: false, description: 'Filter by season'
      parameter name: :zone, in: :query, type: :string, required: false, description: 'Filter by zone'
      parameter name: :level, in: :query, type: :string, required: false, description: 'Filter by level'

      response(200, 'successful') do
        before do
          create_list(:exam, 3)
        end

        run_test!
      end
    end

    post('create exams') do
      tags 'Admin Exams'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          exam: {
            type: :object,
            properties: {
              paper_id: { type: :string },
              year: { type: :integer },
              season: { type: :string },
              zone: { type: :string },
              level: { type: :string },
              file: { type: :string },
              marking_scheme: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { exam: attributes_for(:exam) } }

        run_test!
      end
    end
  end

  path '/api/v1/admin/exams/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show exams') do
      tags 'Admin Exams'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      response(200, 'successful') do
        run_test!
      end
    end

    put('update exams') do
      tags 'Admin Exams'
      produces 'application/json'
      consumes 'application/json'
      security [{ bearerAuth: nil }]

      parameter name: :data, in: :body, schema: {
        type: :object,
        properties: {
          exam: {
            type: :object,
            properties: {
              paper_id: { type: :string },
              year: { type: :string },
              season: { type: :string },
              zone: { type: :string },
              level: { type: :string },
              file: { type: :string },
              marking_scheme: { type: :string }
            }
          }
        }
      }

      response(200, 'successful', save_request_example: :data) do
        let(:data) { { exam: attributes_for(:exam) } }

        run_test!
      end
    end

    delete('delete exams') do
      tags 'Admin Exams'
      security [{ bearerAuth: nil }]

      response(204, 'successful') do
        run_test!
      end
    end
  end
end
