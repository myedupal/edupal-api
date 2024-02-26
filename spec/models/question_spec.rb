require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:exam) }
    it { is_expected.to have_many(:answers).dependent(:destroy) }
    it { is_expected.to have_many(:question_images).dependent(:destroy) }
    it { is_expected.to have_many(:question_topics).dependent(:destroy) }
    it { is_expected.to have_many(:topics).through(:question_topics) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:answers) }
    it { is_expected.to accept_nested_attributes_for(:question_images) }
    it { is_expected.to accept_nested_attributes_for(:question_topics) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:question_type).with_values({ mcq: 'mcq', text: 'text' }).backed_by_column_of_type(:string) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:number) }

    describe 'uniqueness' do
      subject { create(:question) }

      it { is_expected.to validate_uniqueness_of(:number).case_insensitive.scoped_to(:exam_id) }
    end
  end
end
