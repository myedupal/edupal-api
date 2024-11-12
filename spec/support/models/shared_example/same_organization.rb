RSpec.shared_examples 'same_organization_validator' do |parent_model_symbol|
  let(:current_model_symbol) { described_class.to_s.underscore.to_sym }
  let(:organization) { build(:organization) }
  let(:parent_model) { create(parent_model_symbol, organization: organization) }

  subject { build(current_model_symbol, parent_model_symbol => parent_model, organization: organization) }

  # it 'has organization associations' do
  #   expect(parent_model).to belong_to(:organization).optional
  #   expect(from_model).to belong_to(:organization).optional
  # end

  context 'with same organization' do
    subject { build(current_model_symbol, parent_model_symbol => parent_model, organization: organization) }

    it { is_expected.to be_valid }
  end

  context 'with different organization' do
    # create a valid model first because current model might have multiple child model
    # with validation on the organization
    subject { build(current_model_symbol, parent_model_symbol => parent_model, organization: organization) }

    let(:current_associations) { current_model_symbol.to_s.camelize.constantize.reflect_on_all_associations(:belongs_to).map(&:name) }
    it 'is expected to be invalid' do
      expect(current_associations).to include(parent_model_symbol), "invalid usage: :#{current_model_symbol} is missing a 'belongs_to' association for :#{parent_model_symbol}"

      subject.assign_attributes(organization: build(:organization))
      is_expected.to_not be_valid
    end
  end
end
