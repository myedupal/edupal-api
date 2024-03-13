class Api::V1::Admin::ChallengeSubmissionsController < Api::V1::Admin::ApplicationController
  before_action :set_challenge_submission, only: [:show, :update, :destroy]
  before_action :set_challenge_submissions, only: [:index]

  def index
    @pagy, @challenge_submissions = pagy(@challenge_submissions)
    render json: @challenge_submissions, include: ['challenge.subject.curriculum', 'user']
  end

  def show
    render json: @challenge_submission, include: ['challenge.subject.curriculum', 'user', 'submission_answers.question']
  end

  private

    def set_challenge_submission
      @challenge_submission = pundit_scope(ChallengeSubmission).preload({ submission_answers: :question }).find(params[:id])
      pundit_authorize(@challenge_submission) if @challenge_submission
    end

    def set_challenge_submissions
      pundit_authorize(ChallengeSubmission)
      @challenge_submissions = pundit_scope(ChallengeSubmission.all).preload(:user, { challenge: { subject: :curriculum } })
      @challenge_submissions = @challenge_submissions.where(challenge_id: params[:challenge_id]) if params[:challenge_id].present?
      @challenge_submissions = @challenge_submissions.where(user_id: params[:user_id]) if params[:user_id].present?
      @challenge_submissions = attribute_sortable(@challenge_submissions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::ChallengeSubmissionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::ChallengeSubmissionPolicy)
    end
end
