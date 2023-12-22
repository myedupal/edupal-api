class Api::V1::Stripe::WebhooksController < Api::V1::Stripe::ApplicationController
  include CallbackLoggable

  before_action :log_callback, only: [:create]

  def create
    head :ok
  end
end
