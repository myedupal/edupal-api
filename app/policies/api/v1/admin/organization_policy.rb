class Api::V1::Admin::OrganizationPolicy < ApplicationPolicy

  def show?
    return true if user.super_admin?

    record.accounts.include?(@user) || record.owner == @user
  end

  def create?
    user.super_admin?
  end

  def setup?
    true
  end

  def update?
    return true if user.super_admin?

    record.accounts.include?(@user)
  end

  def destroy?
    return true if user.super_admin?

    record.owner == @user
  end

  def leave?
    true
  end

  class Scope < Scope

    def resolve
      if user.super_admin?
        # Super admins access all resources
        scope.all
      else
        # Organization admins can access resources within the organizations they belong to
        scope.joins(:organization_accounts).where(owner: @user)
          .or(scope.where(organization_accounts: { account_id: @user.id }))
      end
    end
  end
end
