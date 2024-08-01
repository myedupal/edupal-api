class Api::V1::User::GuessWordsController < Api::V1::User::ApplicationController
  before_action :set_guess_word, only: [:show]
  before_action :set_guess_words, only: [:index]

  def index
    @pagy, @guess_words = pagy(@guess_words)
    render json: @guess_words, include: ['subject']
  end

  def show
    render json: @guess_word, include: ['subject', 'guess_word_submissions', 'guess_word_submissions.guesses']
  end

  private

    def set_guess_word
      @guess_word = pundit_scope(GuessWord.includes(:subject, :guess_word_submissions)).find(params[:id])
      pundit_authorize(@guess_word) if @guess_word
    end

    def set_guess_words
      pundit_authorize(GuessWord)
      @guess_words = pundit_scope(GuessWord.includes(:subject, :guess_word_submissions))
      @guess_words = @guess_words.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @guess_words = @guess_words.only_submitted_by_user(current_user) if params[:submitted].present?
      @guess_words = @guess_words.ongoing if params[:ongoing].present?
      @guess_words = @guess_words.ended if params[:ended].present?
      @guess_words = @guess_words.only_submitted_by_user(current_user) if params[:submitted].present?
      @guess_words = @guess_words.only_unsubmitted_by_user(current_user) if params[:unsubmitted].present?
      @guess_words = @guess_words.only_completed_by_user(current_user) if params[:completed].present?
      @guess_words = @guess_words.only_incomplete_by_user(current_user) if params[:incomplete].present?
      @guess_words = @guess_words.only_available_for_user(current_user) if params[:available].present?

      @guess_words = attribute_sortable(@guess_words)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::GuessWordPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::GuessWordPolicy)
    end
end
