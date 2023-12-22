class Api::V1::Admin::SubscriptionsController < Api::V1::Admin::ApplicationController
  before_action :set_subscriptions, only: [:index]

  def index
    @pagy, @subscriptions = pagy(@subscriptions)
    render json: @subscriptions
  end

  private

    def set_subscriptions
      pundit_authorize(Subscription)
      @subscriptions = pundit_scope(Subscription.includes(:plan, :created_by, :price, :user))
      @subscriptions = @subscriptions.where(plan_id: params[:plan_id]) if params[:plan_id].present?
      @subscriptions = @subscriptions.where(user_id: params[:user_id]) if params[:user_id].present?
      @subscriptions = attribute_sortable(@subscriptions)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::SubscriptionPolicy)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::SubscriptionPolicy::Scope)
    end
end
