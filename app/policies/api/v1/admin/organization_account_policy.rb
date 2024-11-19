class Api::V1::Admin::OrganizationAccountPolicy < ApplicationPolicy
  def show?
    @user.super_admin? || record.organization.organization_accounts.where(account_id: @user.id).any?
  end

  def create?
    @user.super_admin?
  end

  def update?
    can_user_manage_account?
  end

  def destroy?
    can_user_manage_account?
  end

  def can_user_manage_account?
    return true if record.organization.nil?
    return true if @user.super_admin?
    return true if record.organization.owner == @user

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
        scope_by_organization
      end
    end
  end
end
