class Api::V1::Admin::GuessWordsController < Api::V1::Admin::ApplicationController
  before_action :set_guess_word, only: [:show, :update, :destroy]
  before_action :set_guess_words, only: [:index]

  def index
    @pagy, @guess_words = pagy(@guess_words)
    render json: @guess_words, include: ['subject']
  end

  def show
    render json: @guess_word, include: ['subject']
  end

  def create
    @guess_word = pundit_scope(GuessWord).new(guess_word_params)
    pundit_authorize(@guess_word)

    if @guess_word.save
      render json: @guess_word, include: ['subject']
    else
      render json: ErrorResponse.new(@guess_word), status: :unprocessable_entity
    end
  end

  def update
    if @guess_word.update(guess_word_params)
      render json: @guess_word, include: ['subject', 'guess_word_submissions']
    else
      render json: ErrorResponse.new(@guess_word), status: :unprocessable_entity
    end
  end

  def destroy
    if @guess_word.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@guess_word), status: :unprocessable_entity
    end
  end

  private

    def set_guess_word
      @guess_word = pundit_scope(GuessWord).find(params[:id])
      pundit_authorize(@guess_word) if @guess_word
    end

    def set_guess_words
      pundit_authorize(GuessWord)
      @guess_words = pundit_scope(GuessWord.includes(:subject))
      @guess_words = @guess_words.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @guess_words = @guess_words.ongoing if params[:ongoing].present?
      @guess_words = @guess_words.ended if params[:ended].present?
      @guess_words = @guess_words.only_submitted_by_user(params[:only_submitted_by]) if params[:only_submitted_by].present?
      @guess_words = @guess_words.only_unsubmitted_by_user(params[:only_unsubmitted_by]) if params[:only_unsubmitted_by].present?
      @guess_words = @guess_words.only_completed_by_user(params[:only_completed_by]) if params[:only_completed_by].present?
      @guess_words = @guess_words.only_available_for_user(params[:only_available_for]) if params[:only_available_for].present?

      @guess_words = keyword_queryable(@guess_words)
      @guess_words = attribute_sortable(@guess_words)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::GuessWordPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::GuessWordPolicy)
    end

    def guess_word_params
      params.require(:guess_word).permit(:subject_id, :answer, :description, :attempts, :reward_points, :start_at, :end_at)
    end
end
