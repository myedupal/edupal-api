require 'rails_helper'

RSpec.describe UserCollectionQuestion, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question) }
    it { is_expected.to belong_to(:user_collection).counter_cache(:questions_count) }
  end

  describe 'validations' do
    describe 'uniqueness' do
      subject { create(:user_collection_question) }
      it { is_expected.to validate_uniqueness_of(:question_id).scoped_to(:user_collection_id).case_insensitive }
    end

    describe 'must_be_same_curriculum' do
      let(:curriculum) { create(:curriculum) }
      let(:user_collection) { create(:user_collection, curriculum: curriculum) }
      let(:question_curriculum) { create(:curriculum) }
      let(:question) { create(:question, subject: create(:subject, curriculum: question_curriculum)) }
      subject(:user_collection_question) { build(:user_collection_question, question: question, user_collection: user_collection) }

      context 'when curriculum is different' do
        it { is_expected.not_to be_valid }
      end
      context 'when curriculum is same' do
        let(:question_curriculum) { curriculum }

        it { is_expected.to be_valid }
      end
    end
  end
end
