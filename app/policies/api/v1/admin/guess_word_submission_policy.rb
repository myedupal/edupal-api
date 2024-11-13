class Api::V1::Admin::GuessWordSubmissionPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope_by_organization
    end
  end
end
