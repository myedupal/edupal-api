require 'swagger_helper'

RSpec.describe 'api/v1/admin/topics', type: :request do
  let(:id) { create(:topic).id }

  path '/api/v1/web/topics' do
    get('list topics') do
      tags 'Web Topics'
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Sort by column name'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :organization_id, in: :query, type: :string, required: false, description: 'Filter by Organization id'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :query, in: :query, type: :string, required: false, description: 'Search by name'

      response(200, 'successful') do
        before do
          create_list(:topic, 3)
        end

        run_test!
      end
    end
  end

  path '/api/v1/web/topics/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show topics') do
      tags 'Web Topics'
      produces 'application/json'

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
