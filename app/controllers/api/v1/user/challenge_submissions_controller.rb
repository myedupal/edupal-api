class Api::V1::User::ChallengeSubmissionsController < Api::V1::User::ApplicationController
  before_action :set_challenge_submission, only: [:show, :update, :destroy, :submit]
  before_action :set_challenge_submissions, only: [:index]

  def index
    @pagy, @challenge_submissions = pagy(@challenge_submissions)
    render json: @challenge_submissions, include: ['challenge.subject.curriculum']
  end

  def show
    render json: @challenge_submission, include: ['*', 'submission_answers.question.*']
  end

  def create
    @challenge_submission = ChallengeSubmission.new(challenge_submission_params)
    @challenge_submission.user_id = current_user.id
    pundit_authorize(@challenge_submission)

    if @challenge_submission.save
      render json: @challenge_submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@challenge_submission), status: :unprocessable_entity
    end
  end

  def update
    if @challenge_submission.update(challenge_submission_params)
      render json: @challenge_submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@challenge_submission), status: :unprocessable_entity
    end
  end

  def destroy
    if @challenge_submission.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@challenge_submission), status: :unprocessable_entity
    end
  end

  def submit
    if @challenge_submission.submit!
      render json: @challenge_submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@challenge_submission), status: :unprocessable_entity
    end
  end

  def direct_submit
    @challenge_submission = ChallengeSubmission.new(challenge_submission_params)
    @challenge_submission.user_id = current_user.id
    pundit_authorize(@challenge_submission)

    if @challenge_submission.save
      @challenge_submission.submit!
      render json: @challenge_submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@challenge_submission), status: :unprocessable_entity
    end
  end

  private

    def set_challenge_submission
      @challenge_submission = pundit_scope(ChallengeSubmission)
                              .preload({ submission_answers: { question: [:exam, :topics, :answers, :question_images] } })
                              .find(params[:id])
      pundit_authorize(@challenge_submission) if @challenge_submission
    end

    def set_challenge_submissions
      pundit_authorize(ChallengeSubmission)
      @challenge_submissions = pundit_scope(ChallengeSubmission.all).preload({ challenge: { subject: :curriculum } })
      @challenge_submissions = @challenge_submissions.where(challenge_id: params[:challenge_id]) if params[:challenge_id].present?
      @challenge_submissions = @challenge_submissions.joins(:challenge).where(challenge: { subject_id: params[:subject_id] }) if params[:subject_id].present?
      @challenge_submissions = @challenge_submissions.where(status: params[:status]) if params[:status].present?
      @challenge_submissions = @challenge_submissions.joins(:challenge).where(challenge: { challenge_type: params[:challenge_type] }) if params[:challenge_type].present?
      @challenge_submissions = attribute_sortable(@challenge_submissions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::ChallengeSubmissionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::ChallengeSubmissionPolicy)
    end

    def challenge_submission_params
      params.require(:challenge_submission).permit(:challenge_id, submission_answers_attributes: [:id, :_destroy, :question_id, :answer])
    end
end
