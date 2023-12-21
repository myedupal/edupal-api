require 'rails_helper'

RSpec.describe Exam, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:paper) }
    it { is_expected.to have_many(:questions).dependent(:destroy) }
    it { is_expected.to have_many(:answers).through(:questions) }
    it { is_expected.to have_many(:question_images).through(:questions) }
    it { is_expected.to have_many(:question_topics).through(:questions) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:year) }
  end
end
