class Api::V1::User::ActivitiesController < Api::V1::User::ApplicationController
  before_action :set_activity, only: [:show, :update, :destroy]
  before_action :set_activities, only: [:index]

  def index
    @pagy, @activities = pagy(@activities)
    render json: @activities, include: ['*', 'subject.curriculum', 'exam.paper']
  end

  def show
    render json: @activity, include: ['*', 'subject.curriculum', 'exam.paper']
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user
    pundit_authorize(@activity)

    if @activity.save
      render json: @activity, include: ['*', 'subject.curriculum', 'exam.paper']
    else
      render json: ErrorResponse.new(@activity), status: :unprocessable_entity
    end
  end

  def update
    if @activity.update(activity_params)
      render json: @activity, include: ['*', 'subject.curriculum', 'exam.paper']
    else
      render json: ErrorResponse.new(@activity), status: :unprocessable_entity
    end
  end

  def destroy
    if @activity.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@activity), status: :unprocessable_entity
    end
  end

  private

    def set_activity
      @activity = pundit_scope(Activity).find(params[:id])
      pundit_authorize(@activity) if @activity
    end

    def set_activities
      pundit_authorize(Activity)
      @activities = pundit_scope(Activity.all).preload({ subject: :curriculum }, { exam: :paper }, :papers, :topics)
      @activities = @activities.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @activities = @activities.where(exam_id: params[:exam_id]) if params[:exam_id].present?
      @activities = @activities.where(activity_type: params[:activity_type]) if params[:activity_type].present?
      @activities = attribute_sortable(@activities)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::ActivityPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::ActivityPolicy)
    end

    def activity_params
      params.require(:activity).permit(
        :subject_id, :exam_id, :activity_type, :title, :recorded_time,
        topic_ids: [], paper_ids: [],
        metadata: [:sort_by, :sort_order, :page, :items, :question_type, { years: [], seasons: [], zones: [], levels: [], numbers: [] }]
      )
    end
end
