class Api::V1::Admin::ChallengePolicy < ApplicationPolicy
  def update?
    @record.start_at > Time.current
  end

  def destroy?
    @record.start_at > Time.current || @record.submissions.empty?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope_by_organization
    end
  end
end
