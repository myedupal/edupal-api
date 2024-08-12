class Api::V1::User::ReferralActivitiesController < Api::V1::User::ApplicationController
  before_action :set_referral_activity, only: [:show]
  before_action :set_referral_activities, only: [:index]

  def index
    @pagy, @referral_activities = pagy(@referral_activities)
    render json: @referral_activities
  end

  def show
    render json: @referral_activity
  end


  private

    def set_referral_activity
      @referral_activity = pundit_scope(ReferralActivity).find(params[:id])
      pundit_authorize(@referral_activity) if @referral_activity
    end

    def set_referral_activities
      pundit_authorize(ReferralActivity)
      @referral_activities = pundit_scope(ReferralActivity)
      @referral_activities = @referral_activities.where(referral_type: params[:referral_type]) if params[:referral_type].present?
      @referral_activities = date_scopable(@referral_activities)
      @referral_activities = attribute_sortable(@referral_activities)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::ReferralActivityPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::ReferralActivityPolicy)
    end
end
