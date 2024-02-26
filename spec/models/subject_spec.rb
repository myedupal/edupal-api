require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:curriculum) }
    it { is_expected.to have_many(:topics).dependent(:destroy) }
    it { is_expected.to have_many(:papers).dependent(:destroy) }
    it { is_expected.to have_many(:exams).through(:papers) }
    it { is_expected.to have_many(:questions).through(:exams) }
    it { is_expected.to have_many(:answers).through(:questions) }
    it { is_expected.to have_many(:question_images).through(:questions) }
    it { is_expected.to have_many(:question_topics).through(:questions) }
  end

  describe 'validations' do
    subject { create(:subject) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:curriculum_id).case_insensitive }
    # it { is_expected.to validate_uniqueness_of(:code).scoped_to(:curriculum_id).allow_nil.case_insensitive }
  end

  describe 'scopes' do
    describe '.query' do
      let!(:mathematics) { create(:subject, name: 'Mathematics', code: 'math') }
      let!(:physics) { create(:subject, name: 'Physics', code: 'phy') }

      it 'returns subjects with matching name or code' do
        expect(described_class.query('math')).to include(mathematics)
        expect(described_class.query('math')).not_to include(physics)
        expect(described_class.query('phy')).to include(physics)
        expect(described_class.query('phy')).not_to include(mathematics)
      end
    end
  end
end
