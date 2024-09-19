class Api::V1::Admin::GuessWordSubmissionsController < Api::V1::Admin::ApplicationController
  before_action :set_guess_word_submission, only: [:show]
  before_action :set_guess_word_submissions, only: [:index]

  def index
    @pagy, @guess_word_submissions = pagy(@guess_word_submissions)
    render json: @guess_word_submissions, include: ['user', 'guess_word']
  end

  def show
    render json: @guess_word_submission, include: ['user', 'guess_word', 'guesses'], include_guesses: true
  end

  private

    def set_guess_word_submission
      @guess_word_submission = pundit_scope(GuessWordSubmission.includes(:user, :guess_word, :guesses)).find(params[:id])
      pundit_authorize(@guess_word_submission) if @guess_word_submission
    end

    def set_guess_word_submissions
      pundit_authorize(GuessWordSubmission)
      @guess_word_submissions = pundit_scope(GuessWordSubmission.includes(:user, :guess_word))
      @guess_word_submissions = @guess_word_submissions.where(guess_word_id: params[:guess_word_id]) if params[:guess_word_id].present?
      @guess_word_submissions = @guess_word_submissions.where(user_id: params[:user_id]) if params[:user_id].present?
      @guess_word_submissions = attribute_sortable(@guess_word_submissions)
      @guess_word_submissions = status_scopable(@guess_word_submissions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::GuessWordSubmissionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::GuessWordSubmissionPolicy)
    end

    def guess_word_submission_params
      params.require(:@guess_word_submission).permit(:subject_id, :answer, :description, :attempts, :reward_points, :start_at, :end_at)
    end
end
