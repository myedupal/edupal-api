require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:organization).optional }
    it { is_expected.to belong_to(:subject) }

    it { is_expected.to have_many(:question_topics).dependent(:destroy) }
    it { is_expected.to have_many(:questions).through(:question_topics) }
    it { is_expected.to have_many(:activity_topics).dependent(:destroy) }
  end

  describe 'validations' do
    subject { create(:topic) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:subject_id).case_insensitive }

    describe 'same_organization_validator' do
      it_behaves_like('same_organization_validator', :subject)
    end
  end

  describe 'scopes' do
    describe '.query' do
      let!(:calculus) { create(:topic, name: 'Calculus') }
      let!(:algebra) { create(:topic, name: 'Algebra') }

      it 'returns topics with matching name' do
        expect(described_class.query('calculus')).to include(calculus)
        expect(described_class.query('calculus')).not_to include(algebra)
        expect(described_class.query('algebra')).to include(algebra)
        expect(described_class.query('algebra')).not_to include(calculus)
      end
    end
  end
end
