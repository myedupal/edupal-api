class Api::V1::User::GuessWordsController < Api::V1::User::ApplicationController
  before_action :set_guess_word, only: [:show]
  before_action :set_guess_words, only: [:index]

  def index
    @pagy, @guess_words = pagy(@guess_words)
    @guess_words = load_guess_word_submissions(@guess_words) if params[:with_submission]
    render json: @guess_words, include: ['subject'], skip_exams_filtering: true
  end

  def show
    render json: @guess_word, include: ['subject', 'guess_word_submissions', 'guess_word_submissions.guesses'], skip_exams_filtering: true
  end

  private

    def set_guess_word
      @guess_word = pundit_scope(GuessWord.includes(:subject, :guess_word_submissions)).find(params[:id])
      @guess_word = load_guess_word_submission(@guess_word) if params[:with_submission]
      pundit_authorize(@guess_word) if @guess_word
    end

    def set_guess_words
      pundit_authorize(GuessWord)
      @guess_words = pundit_scope(GuessWord.includes(:subject, :guess_word_submissions))
      @guess_words = @guess_words.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @guess_words = @guess_words.where(guess_word_pool_id: params[:guess_word_pool_id]) if params.has_key?(:guess_word_pool_id)
      @guess_words = @guess_words.joins(:guess_word_pool).merge(GuessWordPool.where(user_id: nil)) if params[:system_guess_word_pool].present?
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

    def load_guess_word_submissions(guess_words)
      ids = guess_words.pluck(:id)
      guess_word_submissions = GuessWordSubmission.where(user: current_user, guess_word_id: ids).includes(:guesses)

      guess_words.each do |guess_word|
        guess_word.user_guess_word_submissions = guess_word_submissions.select { |gws| gws.guess_word_id == guess_word.id }
      end

      guess_words
    end

    def load_guess_word_submission(guess_word)
      guess_word_submissions = GuessWordSubmission.where(user: current_user, guess_word_id: guess_word.id).includes(:guesses)

      guess_word.user_guess_word_submissions = guess_word_submissions.select { |gws| gws.guess_word_id == guess_word.id }

      guess_word
    end
end
