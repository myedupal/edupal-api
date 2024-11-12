RSpec.shared_examples 'same_organization_to_organization_validator' do |parent_model_symbol, from_model_symbol|
  let(:current_model_symbol) { described_class.to_s.underscore.to_sym }
  let(:organization) { build(:organization) }
  let(:parent_model) { create(parent_model_symbol, organization: organization) }
  let(:from_model) { create(from_model_symbol, organization: organization) }

  subject { build(current_model_symbol, parent_model_symbol => parent_model, from_model_symbol => from_model, organization: organization) }

  # it 'has organization associations' do
  #   expect(parent_model).to belong_to(:organization).optional
  #   expect(from_model).to belong_to(:organization).optional
  # end

  context 'with same organization' do
    it { is_expected.to be_valid }
  end

  context 'with different organization' do
    let(:parent_model) { create(parent_model_symbol, organization: build(:organization)) }

    it { is_expected.to_not be_valid }
  end
end
