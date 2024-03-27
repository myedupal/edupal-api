class Api::V1::User::ActivityQuestionsController < Api::V1::User::ApplicationController
  before_action :set_activity_question, only: [:show, :destroy]
  before_action :set_activity_questions, only: [:index]

  def index
    @pagy, @activity_questions = pagy(@activity_questions)
    render json: @activity_questions
  end

  def show
    render json: @activity_question
  end

  def create
    @activity = policy_scope(Activity.all, policy_scope_class: Api::V1::User::ActivityPolicy::Scope)
                .find(activity_question_params[:activity_id])
    @activity_question = @activity.activity_questions.find_or_create_by(question_id: activity_question_params[:question_id])
    pundit_authorize(@activity_question)

    if @activity_question.save
      render json: @activity_question
    else
      render json: ErrorResponse.new(@activity_question), status: :unprocessable_entity
    end
  end

  def destroy
    if @activity_question.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@activity_question), status: :unprocessable_entity
    end
  end

  private

    def set_activity_question
      @activity_question = pundit_scope(ActivityQuestion).find(params[:id])
      pundit_authorize(@activity_question) if @activity_question
    end

    def set_activity_questions
      pundit_authorize(ActivityQuestion)
      @activity_questions = pundit_scope(ActivityQuestion.includes(:activity, :question))
      @activity_questions = @activity_questions.where(activity_id: params[:activity_id]) if params[:activity_id].present?
      @activity_questions = @activity_questions.where(question_id: params[:question_id]) if params[:question_id].present?
      @activity_questions = attribute_sortable(@activity_questions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::ActivityQuestionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::ActivityQuestionPolicy)
    end

    def activity_question_params
      params.require(:activity_question).permit(:activity_id, :question_id)
    end
end
