class Api::V1::User::GuessWordSubmissionPolicy < ApplicationPolicy
  def guess?
    true
  end

  def direct_guess?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user_id: @user.id)
    end
  end
end
