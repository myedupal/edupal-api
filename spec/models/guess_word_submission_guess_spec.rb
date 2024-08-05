require 'rails_helper'

RSpec.describe GuessWordSubmissionGuess, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:guess_word_submission).counter_cache(:guesses_count) }
    it { is_expected.to have_one(:guess_word).through(:guess_word_submission) }
    it { is_expected.to have_one(:user).through(:guess_word_submission) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:guess) }
    it { is_expected.to validate_presence_of(:result) }
  end

  describe 'callbacks' do
    describe '#set_result' do
      let(:guess_word) { create(:guess_word, answer: answer, attempts: 3) }
      let(:guess_word_submission) { create(:guess_word_submission, guess_word: guess_word) }
      let(:guess_word_submission_guess) { build(:guess_word_submission_guess, guess_word_submission: guess_word_submission, guess: guess) }

      context 'correct word' do
        let(:answer) { 'snack' }
        let(:guess) { 'snack' }

        it 'creates correct response' do
          guess_word_submission_guess.save!
          expect(guess_word_submission_guess.result).to eq(%w[correct correct correct correct correct])
        end
      end

      context 'incorrect word' do
        let(:answer) { 'light' }
        let(:guess) { 'snack' }

        it 'creates exclude response' do
          guess_word_submission_guess.save!
          expect(guess_word_submission_guess.result).to eq(%w[exclude exclude exclude exclude exclude])
        end
      end

      context 'duplicated letters' do
        let(:answer) { 'shape' }
        let(:guess) { 'asset' }

        it 'only show include for the first letter' do
          guess_word_submission_guess.save!
          expect(guess_word_submission_guess.result).to eq(%w[include include exclude include exclude])
        end
      end
    end
  end
end
