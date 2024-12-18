require 'rails_helper'

RSpec.describe ActivityTopic, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:activity) }
    it { is_expected.to belong_to(:topic) }
  end

  describe 'validations' do
    subject { create(:activity_topic) }

    it { is_expected.to validate_uniqueness_of(:topic_id).scoped_to(:activity_id).case_insensitive }

    describe 'same_organization_to_organization_validator' do
      it_behaves_like('same_organization_to_organization_validator', :topic, :activity)
    end
  end
end
