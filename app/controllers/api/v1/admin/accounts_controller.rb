class Api::V1::Admin::AccountsController < Api::V1::Admin::ApplicationController
  def show
    render json: current_admin
  end

  def update
    if current_admin.update(account_params)
      render json: current_admin
    else
      render json: ErrorResponse.new(current_admin), status: :unprocessable_entity
    end
  end

  def password
    if current_admin.update_with_password(password_params)
      render json: current_admin
    else
      render json: ErrorResponse.new(current_admin), status: :unprocessable_entity
    end
  end

  private

    def account_params
      params.require(:account).permit(:name, :email, :selected_organization_id)
    end

    def password_params
      params.require(:account).permit(:current_password, :password, :password_confirmation)
    end
end
