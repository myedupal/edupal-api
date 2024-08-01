class Api::V1::User::GuessWordSubmissionsController < Api::V1::User::ApplicationController
  before_action :set_guess_word_submission, only: [:show, :guess]
  before_action :set_guess_word_submissions, only: [:index, :direct_guess]

  def index
    @pagy, @guess_word_submissions = pagy(@guess_word_submissions)
    render json: @guess_word_submissions, include: ['user', 'guess_word', 'guesses']
  end

  def show
    render json: @guess_word_submission, include: ['user', 'guess_word', 'guesses']
  end

  def create
    @submission = GuessWordSubmission.new(word_guess_submission_params)
    @submission.user_id = current_user.id
    pundit_authorize(@submission)

    if @submission.save
      render json: @submission
    else
      render json: ErrorResponse.new(@submission), status: :unprocessable_entity
    end
  end

  def guess
    if @guess_word_submission.guess!(params[:guess])
      render json: @guess_word_submission
    else
      render json: ErrorResponse.new(@guess_word_submission), status: :unprocessable_entity
    end
  end

  def direct_guess
    @guess_word_submission = @guess_word_submissions.find_or_create_by(user_id: current_user.id)

    if @guess_word_submission.guess!(params[:guess])
      render json: @guess_word_submission
    else
      render json: ErrorResponse.new(@guess_word_submission), status: :unprocessable_entity
    end
  end

  private

    def set_guess_word_submission
      @guess_word_submission = pundit_scope(GuessWordSubmission.includes(:user, :guesses, :guess_word)).find(params[:id])
      pundit_authorize(@guess_word_submission) if @guess_word_submission
    end

    def set_guess_word_submissions
      pundit_authorize(GuessWordSubmission)
      @guess_word_submissions = pundit_scope(GuessWordSubmission.includes(:user, :guesses, :guess_word))
      @guess_word_submissions = @guess_word_submissions.where(guess_word_id: params[:guess_word_id]) if params[:guess_word_id].present?
      @guess_word_submissions = attribute_sortable(@guess_word_submissions)
      @guess_word_submissions = status_scopable(@guess_word_submissions)

    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::GuessWordSubmissionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::GuessWordSubmissionPolicy)
    end

    def word_guess_submission_params
      params.require(:guess_word).permit(:guess_word_id)
    end

end
