class Api::V1::Admin::SessionsController < Devise::SessionsController
  include RackSessionFix
  respond_to :json

  private

    # def sign_in_params
    #   params.require(:admin).permit(:email, :password)
    # end

    # directly override devise respond method since we're only using JSON
    def respond_with(resource, _opts = {})
      render json: resource
    end

    def respond_to_on_destroy
      head :no_content
    end
end
