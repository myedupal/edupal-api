class Api::V1::User::ReferralActivityPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user_id: @user.id, voided: false)
    end
  end
end
