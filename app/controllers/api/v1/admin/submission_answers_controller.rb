class Api::V1::Admin::SubmissionAnswersController < Api::V1::Admin::ApplicationController
  before_action :set_submission_answers, only: [:index]

  def index
    @pagy, @submission_answers = pagy(@submission_answers)
    render json: @submission_answers, include: ['*', 'challenge_submission.challenge.subject.curriculum', 'question.topics', 'question.exam']
  end

  private

    def set_submission_answers
      pundit_authorize(SubmissionAnswer)
      @submission_answers = pundit_scope(SubmissionAnswer.all).preload(:user, { challenge_submission: { challenge: { subject: :curriculum } } }, { question: [:topics, :exam] })
      @submission_answers = @submission_answers.where(challenge_submission_id: params[:challenge_submission_id]) if params[:challenge_submission_id].present?
      @submission_answers = @submission_answers.where(question_id: params[:question_id]) if params[:question_id].present?
      @submission_answers = @submission_answers.where(user_id: params[:user_id]) if params[:user_id].present?
      @submission_answers = attribute_sortable(@submission_answers)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::SubmissionAnswerPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::SubmissionAnswerPolicy)
    end
end
