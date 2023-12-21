class Api::V1::User::ApplicationController < ApplicationController
  before_action :authenticate_user!

  ## define pundit user here if the default user object is not current_user
  def pundit_user
    current_user
  end
end
