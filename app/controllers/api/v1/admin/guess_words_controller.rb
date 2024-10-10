class Api::V1::Admin::GuessWordsController < Api::V1::Admin::ApplicationController
  before_action :set_guess_word, only: [:show, :update, :destroy]
  before_action :set_guess_words, only: [:index, :export_csv]

  def index
    @pagy, @guess_words = pagy(@guess_words)
    render json: @guess_words, include: ['subject'], with_reports: params[:with_reports], skip_exams_filtering: true
  end

  def show
    render json: @guess_word, include: ['subject'], with_reports: params[:with_reports], skip_exams_filtering: true
  end

  def create
    @guess_word = pundit_scope(GuessWord).new(guess_word_params)
    pundit_authorize(@guess_word)

    if @guess_word.save
      render json: @guess_word, include: ['subject']
    else
      render json: ErrorResponse.new(@guess_word), status: :unprocessable_entity, skip_exams_filtering: true
    end
  end

  def update
    if @guess_word.update(guess_word_params)
      render json: @guess_word, include: ['subject', 'guess_word_submissions']
    else
      render json: ErrorResponse.new(@guess_word), status: :unprocessable_entity, skip_exams_filtering: true
    end
  end

  def destroy
    if @guess_word.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@guess_word), status: :unprocessable_entity
    end
  end

  def export_csv
    csv_map = {
      id: 'id',
      subject: 'subject.name',
      answer: 'answer',
      description: 'description',
      attempts: 'attempts',
      start_at: 'start_at',
      end_at: 'end_at',
      reward_points: 'reward_points',
      guess_word_submissions_count: 'guess_word_submissions_count',
      completed_count: 'completed_count',
      avg_guesses_count: 'avg_guesses_count',
      in_progress_count: 'in_progress_count',
      success_count: 'success_count',
      expired_count: 'expired_count',
      failed_count: 'failed_count',
      created_at: 'created_at'
    }

    csv_headers = csv_map.keys
    csv_attributes = csv_map.values

    @guess_words = @guess_words.with_reports
    stream_csv enumerate_csv(@guess_words, csv_headers, csv_attributes), filename: "guess_words_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
  end

  private

    def set_guess_word
      @guess_word = pundit_scope(GuessWord)
      @guess_word = @guess_word.with_reports if params[:with_reports]
      @guess_word = @guess_word.find(params[:id])
      pundit_authorize(@guess_word) if @guess_word
    end

    def set_guess_words
      pundit_authorize(GuessWord)
      @guess_words = pundit_scope(GuessWord.includes(:subject))
      @guess_words = @guess_words.with_reports if params[:with_reports]
      @guess_words = @guess_words.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @guess_words = @guess_words.where(guess_word_pool_id: params[:guess_word_pool_id].presence || nil) if params.has_key?(:guess_word_pool_id)
      @guess_words = @guess_words.joins(:guess_word_pool).merge(GuessWordPool.where(user_id: nil)) if params[:system_guess_word_pool].present?
      @guess_words = @guess_words.ongoing if params[:ongoing].present?
      @guess_words = @guess_words.ended if params[:ended].present?
      @guess_words = @guess_words.only_submitted_by_user(params[:only_submitted_by]) if params[:only_submitted_by].present?
      @guess_words = @guess_words.only_unsubmitted_by_user(params[:only_unsubmitted_by]) if params[:only_unsubmitted_by].present?
      @guess_words = @guess_words.only_completed_by_user(params[:only_completed_by]) if params[:only_completed_by].present?
      @guess_words = @guess_words.only_available_for_user(params[:only_available_for]) if params[:only_available_for].present?

      @guess_words = keyword_queryable(@guess_words)
      @guess_words = attribute_sortable(@guess_words)
      @guess_words = custom_date_scopable(@guess_words, ['start_at', 'end_at', 'created_at', 'updated_at'])
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
