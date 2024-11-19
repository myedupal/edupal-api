class Api::V1::Admin::QuestionImagePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.joins(:question).where(question: { organization_id: @user.selected_organization })
    end
  end
end
