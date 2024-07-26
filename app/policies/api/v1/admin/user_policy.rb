class Api::V1::Admin::UserPolicy < ApplicationPolicy
  def destroy?
    false
  end

  def count?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
