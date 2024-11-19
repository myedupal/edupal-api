class Api::V1::User::OrganizationInvitationPolicy < ApplicationPolicy
  def show?
    record.account == @user || record.email == @user.email.downcase || record.group_invite?
  end

  def lookup?
    true
  end

  def accept?
    record.account == @user || record.email == @user.email.downcase || record.group_invite?
  end

  def reject?
    record.account == @user || record.email == @user.email.downcase || record.group_invite?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(account_id: @user.id).or(scope.where(email: @user.email.downcase)).or(scope.where(invite_type: :group_invite))
    end
  end
end
