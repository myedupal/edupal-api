class Api::V1::User::StudyGoalsController < Api::V1::User::ApplicationController
  before_action :set_study_goal, only: [:show, :update, :destroy]
  before_action :set_study_goals, only: [:index]

  def index
    @pagy, @study_goals = pagy(@study_goals)
    render json: @study_goals, skip_subjects: true
  end

  def show
    render json: @study_goal, include: ['*', 'study_goal_subjects.subject']
  end

  def create
    @study_goal = StudyGoal.new(study_goal_params)
    @study_goal.user_id = current_user.id
    pundit_authorize(@study_goal)

    if @study_goal.save
      render json: @study_goal, include: ['*', 'study_goal_subjects.subject']
    else
      render json: ErrorResponse.new(@study_goal), status: :unprocessable_entity
    end
  end

  def update
    if @study_goal.update(study_goal_params)
      render json: @study_goal, include: ['*', 'study_goal_subjects.subject']
    else
      render json: ErrorResponse.new(@study_goal), status: :unprocessable_entity
    end
  end

  def destroy
    if @study_goal.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@study_goal), status: :unprocessable_entity
    end
  end

  private

    def set_study_goal
      @study_goal = pundit_scope(StudyGoal.includes(:curriculum, study_goal_subjects: :subject)).find(params[:id])
      pundit_authorize(@study_goal) if @study_goal
    end

    def set_study_goals
      pundit_authorize(StudyGoal)
      @study_goals = pundit_scope(StudyGoal.includes(:curriculum))
      @study_goals = @study_goals.where(curriculum_id: current_user.selected_curriculum_id) if params[:current_curriculum].present?
      @study_goals = @study_goals.where(curriculum_id: params[:curriculum_id]) if params[:curriculum_id].present?
      @study_goals = attribute_sortable(@study_goals)
      @study_goals = status_scopable(@study_goals)

    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::StudyGoalPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::StudyGoalPolicy)
    end

    def study_goal_params
      params.require(:study_goal).permit(:curriculum_id, :a_grade_count, study_goal_subjects_attributes: [:id, :subject_id, :_destroy])
    end

end
