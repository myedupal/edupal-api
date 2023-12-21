require 'rails_helper'

RSpec.describe QuestionImage, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:question) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:image) }
  end
end
