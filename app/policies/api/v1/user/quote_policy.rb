class Api::V1::User::QuotePolicy < ApplicationPolicy
  def show?
    record.user_id == @user.id
  end

  def accept?
    record.user_id == @user.id
  end

  def payment_intent?
    record.user_id == @user.id
  end

  def cancel?
    record.user_id == @user.id
  end

  def show_pdf?
    record.user_id == @user.id
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user_id: user.id)
    end
  end
end
