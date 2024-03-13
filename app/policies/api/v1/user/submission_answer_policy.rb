class Api::V1::User::SubmissionAnswerPolicy < ApplicationPolicy
  def create?
    if record.challenge_submission.present?
      record.challenge_submission.pending? && record.user_id == user.id
    else
      record.user_id == user.id
    end
  end

  def update?
    if record.challenge_submission.present?
      record.challenge_submission.pending? && record.user_id == user.id
    else
      record.user_id == user.id && record.evaluated_at.nil?
    end
  end

  def destroy?
    if record.challenge_submission.present?
      record.challenge_submission.pending? && record.user_id == user.id
    else
      record.user_id == user.id && record.evaluated_at.nil?
    end
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user_id: @user.id)
    end
  end
end
