require 'swagger_helper'

RSpec.describe 'api/v1/user/questions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:question) { create(:question) }
  let(:id) { question.id }

  path '/api/v1/user/questions' do
    get('list questions') do
      tags 'User Questions'
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
      parameter name: :year, in: :query, type: :string, required: false, description: 'Filter by year'
      parameter name: :season, in: :query, type: :string, required: false, description: 'Filter by season'
      parameter name: :zone, in: :query, type: :string, required: false, description: 'Filter by zone'
      parameter name: :level, in: :query, type: :string, required: false, description: 'Filter by level'
      parameter name: :question_type, in: :query, type: :string, required: false, description: 'Filter by question type'

      response(200, 'successful') do
        before do
          create_list(:question, 3).each do |question|
            create(:question_image, question: question)
            create(:question_topic, question: question)
            create(:answer, question: question)
          end
        end

        run_test!
      end
    end
  end

  path '/api/v1/user/questions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show questions') do
      tags 'User Questions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      before do
        create(:question_image, question: question)
        create(:question_topic, question: question)
        create(:answer, question: question)
      end

      response(200, 'successful') do
        run_test!
      end
    end
  end
end
