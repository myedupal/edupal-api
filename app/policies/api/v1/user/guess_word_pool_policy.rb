class Api::V1::User::GuessWordPoolPolicy < ApplicationPolicy
  def show?
    record.user_id == @user.id || record.published
  end

  def update?
    record.user_id == @user.id
  end

  def destroy?
    record.user_id == @user.id
  end

  def import?
    record.user_id == @user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user_id: @user.id).or(scope.where(user_id: nil, published: true))
    end
  end
end
