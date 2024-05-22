class Api::V1::Admin::SubmissionsController < Api::V1::Admin::ApplicationController
  before_action :set_submission, only: [:show, :update, :destroy]
  before_action :set_submissions, only: [:index]

  def index
    @pagy, @submissions = pagy(@submissions)
    render json: @submissions, include: ['challenge.subject.curriculum', 'user']
  end

  def show
    render json: @submission, include: ['challenge.subject.curriculum', 'user', 'submission_answers.question']
  end

  private

    def set_submission
      @submission = pundit_scope(Submission).preload({ submission_answers: :question }).find(params[:id])
      pundit_authorize(@submission) if @submission
    end

    def set_submissions
      pundit_authorize(Submission)
      @submissions = pundit_scope(Submission.all).preload(:user, { challenge: { subject: :curriculum } })
      @submissions = @submissions.where(challenge_id: params[:challenge_id]) if params[:challenge_id].present?
      @submissions = @submissions.where(user_id: params[:user_id]) if params[:user_id].present?
      @submissions = attribute_sortable(@submissions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::SubmissionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::SubmissionPolicy)
    end
end
