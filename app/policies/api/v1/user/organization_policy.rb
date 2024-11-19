class Api::V1::User::OrganizationPolicy < ApplicationPolicy
  def show?
    record.organization_accounts.where(account_id: @user.id).any?
  end

  def leave?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:organization_accounts)
        .where(organization_accounts: { account_id: user.id })
    end
  end
end
