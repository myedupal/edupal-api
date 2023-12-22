require 'swagger_helper'

RSpec.describe 'api/v1/web/plans', type: :request do
  path '/api/v1/web/plans' do
    get('list plans') do
      tags 'Web Plans'
      produces 'application/json'

      response(200, 'successful') do
        before do
          create_list(:plan, 3)
        end

        run_test!
      end
    end
  end
end
