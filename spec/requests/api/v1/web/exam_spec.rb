require 'swagger_helper'

RSpec.describe 'api/v1/web/exams', type: :request do
  # change the create(:user) to respective user model name
  let(:id) { create(:exam).id }

  path '/api/v1/web/exams' do
    get('list exams') do
      tags 'Web Exams'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :organization_id, in: :query, type: :string, required: false, description: 'Filter by Organization id'
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
  end

  path '/api/v1/web/exams/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show exams') do
      tags 'Web Exams'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
