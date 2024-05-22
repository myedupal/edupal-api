require 'swagger_helper'

RSpec.describe 'api/v1/web/subjects', type: :request do
  let(:id) { create(:subject).id }

  path '/api/v1/web/subjects' do
    get('list subjects') do
      tags 'Web Subjects'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :curriculum_id, in: :query, type: :string, required: false, description: 'Filter by curriculum id'
      parameter name: :code, in: :query, type: :string, required: false, description: 'Filter by code'
      parameter name: :name, in: :query, type: :string, required: false, description: 'Filter by name'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name or code'
      parameter name: :has_mcq_questions, in: :query, type: :boolean, required: false, description: 'Filter by has mcq questions'

      response(200, 'successful') do
        before do
          create_list(:subject, 3)
        end

        run_test!
      end
    end
  end

  path '/api/v1/web/subjects/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show subjects') do
      tags 'Web Subjects'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
