class Api::V1::Admin::OrganizationInvitationPolicy < ApplicationPolicy
  def show?
    can_user_manage_invitation?
  end

  def create?
    can_user_manage_invitation?
  end

  def update?
    can_user_manage_invitation?
  end

  def destroy?
    can_user_manage_invitation?
  end

  def can_user_manage_invitation?
    return true if record.organization.nil?
    return true if @user.super_admin?

    if %w[admin trainer].include?(record.role)
      record.organization.organization_accounts.where(account_id: @user.id, role: :admin).any?
    else
      record.organization.organization_accounts.where(account_id: @user.id, role: [:admin, :trainer]).any?
    end
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if @user.super_admin?
        scope.all
      else
        scope.joins(organization: :organization_accounts)
          .where(organization: { organization_accounts: { account_id: user.id } })
      end
    end
  end
end
