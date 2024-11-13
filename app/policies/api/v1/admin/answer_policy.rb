class Api::V1::Admin::AnswerPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all.joins(:question).where(questions: { organization: user.selected_organization })
    end
  end
end
