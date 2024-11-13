class Api::V1::User::SavedUserExamPolicy < ApplicationPolicy
  def destroy?
    record.user_id == @user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope_by_organization.where(user_id: @user.id)
    end
  end
end
