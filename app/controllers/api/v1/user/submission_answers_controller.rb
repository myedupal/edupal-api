class Api::V1::User::SubmissionAnswersController < Api::V1::User::ApplicationController
  before_action :set_submission_answer, only: [:show, :update, :destroy]
  before_action :set_submission_answers, only: [:index]

  def index
    @pagy, @submission_answers = pagy(@submission_answers)
    render json: @submission_answers, include: ['*', 'challenge_submission.challenge.subject.curriculum', 'question.subject.curriculum']
  end

  def show
    render json: @submission_answer, include: ['*', 'challenge_submission.challenge.subject.curriculum', 'question.subject.curriculum', 'question.*']
  end

  def create
    @submission_answer = SubmissionAnswer.new(submission_answer_params)
    @submission_answer.user_id = current_user.id
    pundit_authorize(@submission_answer)

    if @submission_answer.save
      render json: @submission_answer, include: ['*', 'challenge_submission.challenge.subject.curriculum', 'question.subject.curriculum', 'question.*']
    else
      render json: ErrorResponse.new(@submission_answer), status: :unprocessable_entity
    end
  end

  def update
    if @submission_answer.update(submission_answer_params)
      render json: @submission_answer, include: ['*', 'challenge_submission.challenge.subject.curriculum', 'question.subject.curriculum', 'question.*']
    else
      render json: ErrorResponse.new(@submission_answer), status: :unprocessable_entity
    end
  end

  def destroy
    if @submission_answer.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@submission_answer), status: :unprocessable_entity
    end
  end

  private

    def set_submission_answer
      @submission_answer = pundit_scope(SubmissionAnswer).find(params[:id])
      pundit_authorize(@submission_answer) if @submission_answer
    end

    def set_submission_answers
      pundit_authorize(SubmissionAnswer)
      @submission_answers = pundit_scope(SubmissionAnswer.all).preload({ challenge_submission: { challenge: { subject: :curriculum } } }, { question: { subject: :curriculum } })
      @submission_answers = @submission_answers.where(challenge_submission_id: params[:challenge_submission_id]) if params[:challenge_submission_id].present?
      @submission_answers = @submission_answers.where(question_id: params[:question_id]) if params[:question_id].present?
      @submission_answers = attribute_sortable(@submission_answers)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::SubmissionAnswerPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::SubmissionAnswerPolicy)
    end

    def submission_answer_params
      params.require(:submission_answer).permit(:challenge_submission_id, :question_id, :answer, :recorded_time)
    end
end
