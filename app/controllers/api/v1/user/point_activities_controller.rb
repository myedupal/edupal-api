class Api::V1::User::PointActivitiesController < Api::V1::User::ApplicationController
  before_action :set_point_activities, only: :index

  def index
    @pagy, @point_activities = pagy(@point_activities)
    render json: @point_activities, status: :ok
  end

  private

    def set_point_activities
      @point_activities = current_user.point_activities.preload(:activity)
      @point_activities = @point_activities.where(action_type: params[:action_type]) if params[:action_type].present?
      @point_activities = date_scopable(@point_activities)
      @point_activities = attribute_sortable(@point_activities)
    end
end
