class Api::V1::Admin::PasswordsController < Devise::PasswordsController
  include RackSessionFix
  respond_to :json

  private

    def respond_with(resource, _opts = {})
      if resource.present? && resource.errors.present?
        render json: ErrorResponse.new(resource), status: :unprocessable_entity
      else
        render json: resource, adapter: :json
      end
    end

    def after_resetting_password_path_for(_resource)
      nil
    end
end
