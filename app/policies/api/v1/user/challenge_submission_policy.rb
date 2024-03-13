class Api::V1::User::ChallengeSubmissionPolicy < ApplicationPolicy
  def update?
    record.user_id == user.id && record.pending?
  end

  def destroy?
    record.user_id == user.id && record.pending?
  end

  def submit?
    true
  end

  def direct_submit?
    create? && submit?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user_id: @user.id)
    end
  end
end
