class Api::V1::User::RegistrationsController < Devise::RegistrationsController
  include RackSessionFix
  respond_to :json

  private

    def sign_up_params
      params.require(:user).permit(:email, :password, :name, :phone_number)
    end

    def respond_with(resource, _opts = {})
      if resource.errors.any?
        render json: ErrorResponse.new(resource), status: :unprocessable_entity
      else
        render json: resource
      end
    end
end
