require 'rails_helper'

RSpec.describe ActivityPaper, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:activity) }
    it { is_expected.to belong_to(:paper) }
  end

  describe 'validations' do
    subject { create(:activity_paper) }

    it { is_expected.to validate_uniqueness_of(:paper_id).scoped_to(:activity_id).case_insensitive }
  end
end
