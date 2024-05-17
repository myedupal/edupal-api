class Api::V1::User::AccountsController < Api::V1::User::ApplicationController
  def show
    render json: current_user, serializer: Api::V1::User::UserWithActiveSubscriptionSerializer
  end

  def update
    if current_user.update(account_params)
      render json: current_user
    else
      render json: ErrorResponse.new(current_user), status: :unprocessable_entity
    end
  end

  def password
    if current_user.update_with_password(password_params)
      render json: current_user
    else
      render json: ErrorResponse.new(current_user), status: :unprocessable_entity
    end
  end

  def zklogin_salt
    render json: { zklogin_salt: current_user.zklogin_salt }
  end

  private

    def account_params
      params.require(:account).permit(:name)
    end

    def password_params
      params.require(:account).permit(:current_password, :password, :password_confirmation)
    end
end
