require 'rails_helper'

RSpec.describe UserCollection, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:curriculum) }
    it { is_expected.to have_many(:user_collection_questions).dependent(:destroy) }
    it { is_expected.to have_many(:questions).through(:user_collection_questions).counter_cache(:questions_count) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:collection_type).with_values({ flashcard: 'flashcard', flagged: 'flagged' }).backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:user_collection_questions).allow_destroy(true) }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe '#set_title' do
        let(:user_collection) { build(:user_collection, title: nil) }

        context 'when flashcard' do
          before { user_collection.flashcard! }
          it { expect(user_collection.title).to eq('Flashcards') }
        end

        context 'when flagged' do
          before { user_collection.flagged! }
          it { expect(user_collection.title).to eq('Flagged Questions') }
        end
      end
    end
  end

  describe 'counter cache' do
    let(:user_collection) { create(:user_collection) }
    before do
      create_list(:user_collection_question, 10, user_collection: user_collection)
    end
    it 'has counter cache' do
      expect(user_collection.reload.questions_count).to eq 10
      expect(user_collection.questions.count).to eq 10
    end
  end
end
