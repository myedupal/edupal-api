require 'rails_helper'

RSpec.describe GuessWordDictionary, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:word) }

    context 'validate_uniqueness_of' do
      subject { create(:guess_word_dictionary) }

      it { is_expected.to validate_uniqueness_of(:word).case_insensitive }
    end

  end

  describe 'callbacks' do
    describe '#downcase_word' do
      it 'downcase word before saving' do
        guess_word_dictionary = build(:guess_word_dictionary, word: 'TEST')
        expect do
          guess_word_dictionary.save!
        end.to change(guess_word_dictionary, :word).from('TEST').to('test')
      end
    end
  end

  describe 'scopes' do
    describe '.query' do
      it 'returns guess word dictionary matching the keyword' do
        guess_word_dictionary = create(:guess_word_dictionary, word: 'test word')
        create(:guess_word_dictionary, word: 'another word')
        expect(described_class.query('test')).to eq([guess_word_dictionary])
      end
    end
  end
end
