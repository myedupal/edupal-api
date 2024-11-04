class OrganizationAccount < ApplicationRecord
  belongs_to :organization, counter_cache: :current_headcount
  belongs_to :account

  has_one :selecting_account, foreign_key: :selected_organization_id, primary_key: :organization_id, dependent: :nullify, class_name: 'Account'

  enum role: {
    admin: 'admin',
    trainer: 'trainer',
    trainee: 'trainee'
  }

  validate :account_id_not_changed
  before_commit :fix_owner_role_as_admin, unless: -> { frozen? }
  before_destroy :cannot_delete_org_owner, unless: -> { destroyed_by_association.present? && destroyed_by_association.active_record == Organization }

  private

    def account_id_not_changed
      if account_id_changed? && persisted?
        errors.add(:account_id, 'cannot be changed')
      end
    end

    def fix_owner_role_as_admin
      return unless organization.owner == account

      admin!
    end

    def cannot_delete_org_owner
      return unless organization.owner == account

      errors.add(:base, 'Cannot delete organization owner')
      throw(:abort)
    end
end
