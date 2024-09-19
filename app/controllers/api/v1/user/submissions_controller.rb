class Api::V1::User::SubmissionsController < Api::V1::User::ApplicationController
  before_action :set_submission, only: [:show, :update, :destroy, :submit]
  before_action :set_submissions, only: [:index]

  def index
    @pagy, @submissions = pagy(@submissions)
    render json: @submissions, include: ['challenge.subject.curriculum']
  end

  def show
    render json: @submission, include: ['*', 'submission_answers.question.*']
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.user_id = current_user.id
    pundit_authorize(@submission)

    if @submission.save
      render json: @submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@submission), status: :unprocessable_entity
    end
  end

  def update
    if @submission.update(submission_params)
      render json: @submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@submission), status: :unprocessable_entity
    end
  end

  def destroy
    if @submission.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@submission), status: :unprocessable_entity
    end
  end

  def submit
    if @submission.submit!
      render json: @submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@submission), status: :unprocessable_entity
    end
  end

  def direct_submit
    @submission = Submission.new(submission_params)
    @submission.user_id = current_user.id
    pundit_authorize(@submission)

    if @submission.save
      @submission.submit!
      render json: @submission, include: ['*', 'submission_answers.question.*']
    else
      render json: ErrorResponse.new(@submission), status: :unprocessable_entity
    end
  end

  private

    def set_submission
      @submission = pundit_scope(Submission)
                    .preload({ submission_answers: { question: [:exam, :topics, :answers, :question_images] } })
                    .find(params[:id])
      pundit_authorize(@submission) if @submission
    end

    def set_submissions
      pundit_authorize(Submission)
      @submissions = pundit_scope(Submission.all).preload({ challenge: { subject: :curriculum } })
      @submissions = @submissions.where(challenge_id: params[:challenge_id]) if params[:challenge_id].present?
      @submissions = @submissions.joins(:challenge).where(challenge: { subject_id: params[:subject_id] }) if params[:subject_id].present?
      @submissions = @submissions.where(status: params[:status]) if params[:status].present?
      @submissions = @submissions.joins(:challenge).where(challenge: { challenge_type: params[:challenge_type] }) if params[:challenge_type].present?
      @submissions = @submissions.daily_challenge if params[:daily_challenge].present? && ActiveModel::Type::Boolean.new.cast(params[:daily_challenge])
      @submissions = @submissions.mcq if params[:mcq].present? && ActiveModel::Type::Boolean.new.cast(params[:mcq])
      @submissions = @submissions.where(mcq_type: params[:mcq_type]) if params[:mcq_type].present?
      @submissions = @submissions.is_user_exam(ActiveModel::Type::Boolean.new.cast(params[:user_exam])) if params[:user_exam].present?
      @submissions = @submissions.where(user_exam_id: params[:user_exam_id]) if params[:user_exam_id].present?

      @submissions = attribute_sortable(@submissions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::SubmissionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::SubmissionPolicy)
    end

    def submission_params
      params.require(:submission).permit(:challenge_id, :user_exam_id, :title, :mcq_type, submission_answers_attributes: [:id, :_destroy, :question_id, :answer])
    end
end
