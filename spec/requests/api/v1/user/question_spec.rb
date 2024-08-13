require 'swagger_helper'

RSpec.describe 'api/v1/user/questions', type: :request do
  # change the create(:user) to respective user model name
  let(:user) { create(:user) }
  let(:Authorization) { bearer_token_for(user) }
  let(:curriculum) { create(:curriculum) }
  let(:subject) { create(:subject, curriculum: curriculum) }
  let(:question) { create(:question, subject: subject) }
  let(:id) { question.id }

  path '/api/v1/user/questions' do
    get('list questions') do
      tags 'User Questions'
      security [{ bearerAuth: nil }]
      produces 'application/json'

      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :items, in: :query, type: :integer, required: false, description: 'Number of items per page'
      parameter name: :sort_by, in: :query, type: :string, required: false,
                description: 'Sort by column name. When sort_by is topic, it will be sorted by topic display order ASC (default) and question number ASC.'
      parameter name: :sort_order, in: :query, type: :string, required: false, description: 'Sort order'
      parameter name: :subject_id, in: :query, type: :string, required: false, description: 'Filter by subject id'
      parameter name: :paper_id, in: :query, type: :string, required: false, description: 'Filter by paper id'
      parameter name: :paper_name, in: :query, type: :string, required: false, description: 'Filter by paper name'
      parameter name: :topic_id, in: :query, type: :string, required: false, description: 'Filter by topic id'
      parameter name: :exam_id, in: :query, type: :string, required: false, description: 'Filter by exam id'
      parameter name: :number, in: :query, type: :string, required: false, description: 'Filter by number'
      parameter name: :year, in: :query, type: :string, required: false, description: 'Filter by year'
      parameter name: :season, in: :query, type: :string, required: false, description: 'Filter by season'
      parameter name: :zone, in: :query, type: :string, required: false, description: 'Filter by zone'
      parameter name: :level, in: :query, type: :string, required: false, description: 'Filter by level'
      parameter name: :question_type, in: :query, type: :string, required: false, description: 'Filter by question type'
      parameter name: :activity_id, in: :query, type: :string, required: false, description: 'Return a helper activity_question_presence for the given activity_id'
      parameter name: :with_collections, in: :query, type: :boolean, required: false, description: 'Include user collection'

      response(200, 'successful') do
        let(:with_collections) { true }
        let(:collection) { create(:user_collection, user: user, curriculum: curriculum) }
        let(:another_collection) { create(:user_collection, user: create(:user), curriculum: curriculum) }

        let!(:question) do
          create(:question, subject: subject).tap do |question|
            create(:user_collection_question, user_collection: collection, question: question)
            create(:user_collection_question, user_collection: create(:user_collection, user: user, curriculum: curriculum), question: question)
            create(:user_collection_question, user_collection: another_collection, question: question)
          end
        end
        before do
          create_list(:question, 2, subject: subject).each do |question|
            create(:question_image, question: question)
            create(:question_topic, question: question)
            create(:answer, question: question)
            create(:user_collection_question, user_collection: collection, question: question)
            create(:user_collection_question, user_collection: another_collection, question: question)
          end

          create(:question, subject: subject).tap do |question|
            create(:answer, question: question)
            create(:user_collection_question, user_collection: another_collection, question: question)
          end
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['questions'].count).to eq(4)
          data['questions'].find { |q| q['id'] == question.id }.tap do |q|
            expect(q['user_collections']).to be_present
            expect(q['user_collections'].count).to eq(2)
          end
        end
      end
    end
  end

  path '/api/v1/user/questions/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :with_collections, in: :query, type: :boolean, required: false, description: 'Include user collection'

    get('show questions') do
      tags 'User Questions'
      produces 'application/json'
      security [{ bearerAuth: nil }]

      let(:with_collections) { true }
      let(:collection) { create(:user_collection, user: user, curriculum: curriculum) }
      before do
        create(:question_image, question: question)
        create(:question_topic, question: question)
        create(:answer, question: question)
        create(:user_collection_question, user_collection: collection, question: question)
      end

      response(200, 'successful') do
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['question']['user_collections'].count).to eq(1)
        end
      end
    end
  end
end
