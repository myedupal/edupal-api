class Api::V1::User::DailyChallengePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.published.where('start_at <= ?', Time.current)
    end
  end
end
