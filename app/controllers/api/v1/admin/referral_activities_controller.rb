class Api::V1::Admin::ReferralActivitiesController < Api::V1::Admin::ApplicationController
  before_action :set_referral_activity, only: [:show, :nullify, :revalidate]
  before_action :set_referral_activities, only: [:index]

  def index
    @pagy, @referral_activities = pagy(@referral_activities)
    render json: @referral_activities
  end

  def show
    render json: @referral_activity
  end

  def nullify
    if @referral_activity.nullify!
      render json: @referral_activity
    else
      render json: ErrorResponse.new(@referral_activity), status: :unprocessable_entity
    end
  end

  def revalidate
    if @referral_activity.revalidate!
      render json: @referral_activity
    else
      render json: ErrorResponse.new(@referral_activity), status: :unprocessable_entity
    end
  end

  private

    def set_referral_activity
      @referral_activity = pundit_scope(ReferralActivity).find(params[:id])
      pundit_authorize(@referral_activity) if @referral_activity
    end

    def set_referral_activities
      pundit_authorize(ReferralActivity)
      @referral_activities = pundit_scope(ReferralActivity.includes(:user, :referral_source))
      @referral_activities = @referral_activities.where(user_id: params[:user_id]) if params[:user_id].present?
      @referral_activities = @referral_activities.where(referral_source_id: params[:referral_source_id]) if params[:referral_source_id].present?
      @referral_activities = @referral_activities.where(referral_source_type: params[:referral_source_type]) if params[:referral_source_type].present?
      @referral_activities = @referral_activities.where(referral_type: params[:referral_type]) if params[:referral_type].present?
      @referral_activities = @referral_activities.where(voided: params[:voided]) if params[:voided].present?
      @referral_activities = date_scopable(@referral_activities)
      @referral_activities = attribute_sortable(@referral_activities)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::ReferralActivityPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::ReferralActivityPolicy)
    end
end
