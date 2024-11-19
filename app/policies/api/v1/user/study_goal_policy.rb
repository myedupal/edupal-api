class Api::V1::User::StudyGoalPolicy < ApplicationPolicy
  def show?
    record.user_id == @user.id
  end

  def update?
    record.user_id == @user.id
  end

  def destroy?
    record.user_id == @user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:curriculum).where(user_id: @user.id, curriculum: { organization_id: @user.selected_organization_id })
    end
  end
end
