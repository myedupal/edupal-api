require 'rails_helper'

RSpec.describe ActivityQuestion, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:activity) }
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    subject { create(:activity_question) }

    it { is_expected.to validate_uniqueness_of(:question_id).scoped_to(:activity_id).case_insensitive }

    describe 'same_organization_to_organization_validator' do
      it_behaves_like('same_organization_to_organization_validator', :question, :activity)
    end
  end
end
