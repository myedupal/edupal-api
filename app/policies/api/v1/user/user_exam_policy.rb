class Api::V1::User::UserExamPolicy < ApplicationPolicy
  def show?
    record.created_by_id == @user.id || record.is_public
  end

  def update?
    record.created_by_id == @user.id
  end

  def destroy?
    record.created_by_id == @user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(created_by_id: @user.id)
    end
  end
end
