class Api::V1::User::SubmissionAnswerPolicy < ApplicationPolicy
  def create?
    record.submission.pending? && record.user_id == user.id
  end

  def update?
    record.submission.pending? && record.user_id == user.id
  end

  def destroy?
    record.submission.pending? && record.user_id == user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user_id: @user.id)
    end
  end
end
