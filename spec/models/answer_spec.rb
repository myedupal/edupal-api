require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    context 'when question is mcq' do
      subject { create(:answer, question: create(:question, question_type: :mcq)) }

      it { is_expected.to validate_presence_of(:text) }
    end
  end

  describe 'scopes' do
    describe '.correct' do
      let!(:correct_answer) { create(:answer, is_correct: true) }
      let!(:incorrect_answer) { create(:answer, is_correct: false) }

      it 'filter for correct answer' do
        expect(described_class.correct).to contain_exactly(correct_answer)
      end
    end

    describe '.incorrect' do
      let!(:correct_answer) { create(:answer, is_correct: true) }
      let!(:incorrect_answer) { create(:answer, is_correct: false) }

      it 'filter for incorrect answer' do
        expect(described_class.incorrect).to contain_exactly(incorrect_answer)
      end
    end
  end
end
