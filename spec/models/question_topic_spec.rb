require 'rails_helper'

RSpec.describe QuestionTopic, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question) }
    it { is_expected.to belong_to(:topic) }
  end

  describe 'validations' do
    subject { create(:question_topic) }

    it { is_expected.to validate_uniqueness_of(:question_id).scoped_to(:topic_id).case_insensitive }
  end
end
