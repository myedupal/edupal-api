class Api::V1::Admin::UserPolicy < ApplicationPolicy


  def index?
    @user.super_admin?
  end

  def show?
    @user.super_admin?
  end

  def create?
    @user.super_admin?
  end

  def update?
    @user.super_admin?
  end

  def destroy?
    false
  end

  def count?
    @user.super_admin?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
