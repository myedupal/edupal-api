require 'swagger_helper'

RSpec.describe 'api/v1/web/papers', type: :request do
  let(:id) { create(:paper).id }

  path '/api/v1/web/papers' do
    get('list papers') do
      tags 'Web Papers'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'

      response(200, 'successful') do
        before do
          create_list(:paper, 3)
        end

        run_test!
      end
    end
  end

  path '/api/v1/web/papers/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show papers') do
      tags 'Web Papers'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
