require 'rails_helper'

RSpec.describe GuessWordQuestion, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:guess_word_pool).counter_cache(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:word) }
    describe 'validate_uniqueness_of' do
      subject { create(:guess_word_question) }

      it { is_expected.to validate_uniqueness_of(:word).scoped_to(:guess_word_pool_id).case_insensitive }
    end
  end

  describe 'callbacks' do
    describe '#downcase_word' do
      it 'downcase word before saving' do
        guess_word_question = build(:guess_word_question, word: 'TEST ')
        expect do
          guess_word_question.save!
        end.to change(guess_word_question, :word).from('TEST ').to('test')
      end
    end
  end

  describe 'indexes' do
    it { is_expected.to have_db_index(:guess_word_pool_id) }
    it { is_expected.to have_db_index([:guess_word_pool_id, :word]).unique(true) }
  end
end
