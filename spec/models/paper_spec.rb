require 'rails_helper'

RSpec.describe Paper, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:subject) }
    it { is_expected.to have_many(:exams).dependent(:destroy) }
    it { is_expected.to have_many(:questions).through(:exams) }
    it { is_expected.to have_many(:answers).through(:questions) }
    it { is_expected.to have_many(:question_images).through(:questions) }
    it { is_expected.to have_many(:question_topics).through(:questions) }
  end

  describe 'validations' do
    subject { create(:paper) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:subject_id).case_insensitive }
  end
end
