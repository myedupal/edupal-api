require 'rails_helper'

RSpec.describe ChallengeQuestion, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:challenge) }
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:display_order) }
    it { is_expected.to validate_presence_of(:score) }

    describe 'uniqueness of question_id' do
      let(:challenge) { create(:challenge) }
      let(:question) { create(:question) }
      let!(:challenge_question) { create(:challenge_question, challenge: challenge, question: question) }

      it 'validates uniqueness of question_id' do
        new_challenge_question = build(:challenge_question, challenge: challenge, question: question)
        expect(new_challenge_question).not_to be_valid
      end
    end
  end
end
