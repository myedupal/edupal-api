require 'rails_helper'

RSpec.describe Curriculum, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:subjects).dependent(:destroy) }
    it { is_expected.to have_many(:topics).through(:subjects) }
    it { is_expected.to have_many(:papers).through(:subjects) }
    it { is_expected.to have_many(:exams).through(:papers) }
    it { is_expected.to have_many(:questions).through(:exams) }
    it { is_expected.to have_many(:answers).through(:questions) }
    it { is_expected.to have_many(:question_images).through(:questions) }
    it { is_expected.to have_many(:question_topics).through(:questions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:board).case_insensitive }
    it { is_expected.to validate_presence_of(:board) }
  end

  describe 'scopes' do
    describe '.query' do
      let(:caluk) { create(:curriculum, name: 'A-Level', board: 'Cambridge') }
      let(:stpm) { create(:curriculum, name: 'STPM', board: 'Malaysia') }

      it 'returns curriculums that match the keyword' do
        expect(described_class.query('A-Level')).to include(caluk)
        expect(described_class.query('A-Level')).not_to include(stpm)
        expect(described_class.query('Cambridge')).to include(caluk)
        expect(described_class.query('Cambridge')).not_to include(stpm)
        expect(described_class.query('STPM')).to include(stpm)
        expect(described_class.query('STPM')).not_to include(caluk)
      end
    end
  end
end
