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
end
