require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end
end
