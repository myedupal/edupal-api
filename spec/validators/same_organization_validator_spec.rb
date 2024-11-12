require 'rails_helper'

RSpec.describe SameOrganizationValidator do
  subject(:validator) { described_class.new(attributes: [:parent_model]) }

  # Sample models for testing
  let(:organization) { build(:organization) }
  let(:another_organization) { build(:organization) }
  let(:parent_model) { double("ParentModel", organization: organization) }
  let(:child_model) { double("ChildModel", organization: organization, parent: parent_model, errors: ActiveModel::Errors.new(self)) }

  context 'when both models belong to the same organization' do
    it 'does not add errors to the child model' do
      validator.validate_each(child_model, :parent, parent_model)
      expect(child_model.errors).to be_empty
    end

    context 'with parent_organization organization alias' do
      subject(:validator) { described_class.new(attributes: [:parent_model], record_organization: :organization_aliased, parent_organization: :organization_alias) }
      let(:child_model) { double("ChildModel", organization_aliased: organization, parent: parent_model, errors: ActiveModel::Errors.new(self)) }
      let(:parent_model) { double("ParentModel", organization_alias: organization) }

      it 'does not add errors to the child model' do
        validator.validate_each(child_model, :parent, parent_model)
        expect(child_model.errors).to be_empty
      end
    end
  end

  context 'with a many to many record' do
    subject(:validator) { described_class.new(attributes: [:parent_model], from: :child_model) }
    let(:parent_to_children) { double("ParentToChildrenModel", parent: parent_model, child_model: child_model, errors: ActiveModel::Errors.new(self)) }
    let(:child_model) { double("ChildModel", organization: organization) }

    context 'when both models have the same organization' do
      it 'does not add errors' do
        validator.validate_each(parent_to_children, :parent, parent_model)
        expect(parent_to_children.errors).to be_empty
      end
    end

    context 'when both models have the different organization' do
      let(:child_model) { double("ChildModel", organization: build(:organization)) }

      it 'does add errors' do
        validator.validate_each(parent_to_children, :parent, parent_model)
        expect(parent_to_children.errors.where(:parent, :same_organization)).to be_present
      end
    end

  end

  context 'when both models has no organization' do
    let(:organization) { nil }

    it 'does not add errors to the child model' do
      validator.validate_each(child_model, :parent, parent_model)
      expect(child_model.errors).to be_empty
    end
  end

  context 'when models belong to different organizations' do
    let(:parent_model) { double("ParentModel", organization: another_organization) }

    it 'adds an error to the child model' do
      validator.validate_each(child_model, :parent, parent_model)
      expect(child_model.errors.where(:parent, :same_organization)).to be_present
    end
  end

  context 'when parent model is nil' do
    let(:child_model) { double("ChildModel", organization: organization, parent: nil, errors: ActiveModel::Errors.new(self)) }

    it 'does not add errors to the child model' do
      validator.validate_each(child_model, :parent, nil)
      expect(child_model.errors).to be_empty
    end
  end

  context 'when record does not have the specified organization association' do
    let(:child_model) { double("ChildModel", parent: parent_model, errors: ActiveModel::Errors.new(self), class: 'ChildModel') }

    it 'raises an ArgumentError' do
      expect {
        validator.validate_each(child_model, :parent, parent_model)
      }.to raise_error(ArgumentError, "ChildModel must have an organization association for SameOrganizationValidator")
    end
  end

  context 'when parent does not have the specified organization association' do
    let(:parent_model) { double("ParentModel", class: 'ParentModel') } # No organization association

    it 'raises an ArgumentError' do
      expect {
        validator.validate_each(child_model, :parent, parent_model)
      }.to raise_error(ArgumentError, "ParentModel must have an organization association for SameOrganizationValidator")
    end
  end
end
