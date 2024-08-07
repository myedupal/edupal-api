class Api::V1::Admin::ReferralActivityPolicy < ApplicationPolicy
  def nullify?
    true
  end

  def revalidate?
    true
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
