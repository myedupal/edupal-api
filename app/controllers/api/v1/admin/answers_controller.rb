class Api::V1::Admin::AnswersController < Api::V1::Admin::ApplicationController
  before_action :set_answer, only: [:show, :update, :destroy]
  before_action :set_answers, only: [:index]

  def index
    @pagy, @answers = pagy(@answers)
    render json: @answers
  end

  def show
    render json: @answer
  end

  def create
    @answer = pundit_scope(Answer).new(answer_params)
    pundit_authorize(@answer)

    if @answer.save
      render json: @answer
    else
      render json: ErrorResponse.new(@answer), status: :unprocessable_entity
    end
  end

  def update
    if @answer.update(answer_params)
      render json: @answer
    else
      render json: ErrorResponse.new(@answer), status: :unprocessable_entity
    end
  end

  def destroy
    if @answer.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@answer), status: :unprocessable_entity
    end
  end

  private

    def set_answer
      @answer = pundit_scope(Answer).find(params[:id])
      pundit_authorize(@answer) if @answer
    end

    def set_answers
      pundit_authorize(Answer)
      @answers = pundit_scope(Answer.includes(:question))
      @answers = @answers.where(question_id: params[:question_id]) if params[:question_id].present?
      @answers = attribute_sortable(@answers)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::AnswerPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::AnswerPolicy)
    end

    def answer_params
      params.require(:answer).permit(:question_id, :text, :image)
    end
end
