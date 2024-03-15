class Api::V1::User::ActivityQuestionPolicy < ApplicationPolicy
  def create?
    @record.activity&.user_id == @user.id
  end

  def destroy?
    @record.activity&.user_id == @user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:activity).where(activity: { user_id: @user.id })
    end
  end
end
