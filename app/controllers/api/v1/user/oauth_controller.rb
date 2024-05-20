class Api::V1::User::OauthController < Api::V1::User::ApplicationController
  skip_before_action :authenticate_user!

  def google
    id_token = id_token_params
    payload = Google::Auth::IDTokens.verify_oidc(id_token, aud: ENV.fetch('GOOGLE_OAUTH_CLIENT_ID', nil))
    user = User.find_or_register_by_oauth('google', payload)

    render json: ErrorResponse.new(user.user_registered_by_message), status: :unprocessable_entity unless user.oauth_authenticatable?('google')

    sign_in(user, store: false)

    render json: user, meta: { zklogin_salt: user.zklogin_salt }
  rescue Google::Auth::IDTokens::VerificationError
    render json: ErrorResponse.new('Invalid ID token'), status: :bad_request
  end

  private

    def id_token_params
      params.require(:id_token)
    end
end
