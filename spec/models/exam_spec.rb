require 'rails_helper'

RSpec.describe Exam, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:organization).optional }
    it { is_expected.to belong_to(:paper) }
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:answers).through(:questions) }
    it { is_expected.to have_many(:question_images).through(:questions) }
    it { is_expected.to have_many(:question_topics).through(:questions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:year) }

    describe 'uniqueness' do
      subject { create(:exam) }

      it { is_expected.to validate_uniqueness_of(:year).scoped_to([:paper_id, :season, :zone, :level]).case_insensitive }
    end

    describe 'same_organization_validator' do
      it_behaves_like('same_organization_validator', :paper)
    end
  end
end
