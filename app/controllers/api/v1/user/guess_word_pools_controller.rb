class Api::V1::User::GuessWordPoolsController < Api::V1::User::ApplicationController
  before_action :set_guess_word_pool, only: [:show, :update, :destroy, :import, :daily_guess_word]
  before_action :set_guess_word_pools, only: [:index]

  def index
    @pagy, @guess_word_pools = pagy(@guess_word_pools)
    render json: @guess_word_pools, skip_questions: true
  end

  def show
    render json: @guess_word_pool
  end

  def create
    @guess_word_pool = pundit_scope(GuessWordPool).new(guess_word_pool_params)
    pundit_authorize(@user)

    if @guess_word_pool.save
      render json: @guess_word_pool
    else
      render json: ErrorResponse.new(@guess_word_pool), status: :unprocessable_entity
    end
  end

  def update
    if @guess_word_pool.update(guess_word_pool_params)
      render json: @guess_word_pool
    else
      render json: ErrorResponse.new(@guess_word_pool), status: :unprocessable_entity
    end
  end

  def destroy
    if @guess_word_pool.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@guess_word_pool), status: :unprocessable_entity
    end
  end

  def import
    read = 0
    imported = 0
    key_mapping = { word: :word, description: :description }

    GuessWordQuestion.transaction do
      SmarterCSV.process(
        import_params,
        chunk_size: 1000,
        key_mapping: key_mapping,
        required_keys: key_mapping.values,
        remove_empty_values: false,
        remove_zero_values: false
      ) do |chunk|
        read += chunk.length

        # insert_all does not instantiate any models nor does it trigger Active Record callbacks or validations.
        # therefore word formatting has to be made beforehand
        entries = chunk
                    .map { |entry| { word: entry[:word]&.to_s&.strip&.downcase, description: entry[:description]&.to_s&.strip } }
                    .select { |entry| entry[:word].present? }
                    .uniq { |entry| entry[:word] }

        result = @guess_word_pool.guess_word_questions.upsert_all(
          entries,
          unique_by: [:guess_word_pool_id, :word],
          returning: :id,
          update_only: :description
        )
        imported += result.length
      end
    end

    render json: @guess_word_pool.reload, meta: { read: read, imported: imported }
  rescue SmarterCSV::MissingKeys => e
    render json: ErrorResponse.new("Missing CSV keys: #{e.message}"), status: :unprocessable_entity
  rescue SmarterCSV::Error => e
    render json: ErrorResponse.new("Error Parsing CSV: #{e.message}"), status: :unprocessable_entity
  end

  def daily_guess_word
    unless @guess_word_pool.daily_guess_word.present?
      guess_word_question = @guess_word_pool.guess_word_questions.order('RANDOM()').first
      @guess_word_pool.create_daily_guess_word!(
        subject: @guess_word_pool.subject,
        answer: guess_word_question.word,
        description: guess_word_question.description,
        attempts: 6,
        reward_points: 0
      )
    end

    render json: @guess_word_pool, include_daily_guess_word: true
  end

  private

    def set_guess_word_pool
      @guess_word_pool = pundit_scope(
        GuessWordPool.includes(:guess_word_questions)
      ).find(params[:id])
      pundit_authorize(@guess_word_pool) if @guess_word_pool
    end

    def set_guess_word_pools
      pundit_authorize(GuessWordPool)
      @guess_word_pools = pundit_scope(GuessWordPool)
      @guess_word_pools = @guess_word_pools.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @guess_word_pools = @guess_word_pools.by_curriculum(params[:curriculum_id]) if params[:curriculum_id].present?
      @guess_word_pools = @guess_word_pools.by_curriculum(current_user.selected_curriculum.id) if params[:current_curriculum].present?
      @guess_word_pools = @guess_word_pools.where(user_id: params[:user_id].presence || nil) if params.has_key?(:user_id)
      @guess_word_pools = @guess_word_pools.where(published: boolean(params[:published])) if params[:published].present?

      if params[:include_default_pool].present? || params[:include_self].present? || params[:include_user_id].present? || params[:include_system].present? || params[:include_other].present?
        conditions = []

        conditions << GuessWordPool.where(default_pool: true) if boolean(:include_default_pool)
        conditions << GuessWordPool.where(user_id: current_user.id) if boolean(params[:include_self])
        conditions << GuessWordPool.where(user_id: params[:include_user_id]) if params[:include_user_id].present?
        conditions << GuessWordPool.where(user_id: nil) if boolean(params[:include_system])
        conditions << GuessWordPool.where.not(user_id: nil) if boolean(params[:include_user])

        combined_conditions = conditions.reduce { |query, condition| query.or(condition) }
        @guess_word_pools = @guess_word_pools.merge(combined_conditions)
      else
        @guess_word_pools = @guess_word_pools.where(user_id: current_user.id).or(GuessWordPool.where(user_id: nil))
      end
      @guess_word_pools = keyword_queryable(@guess_word_pools)
      @guess_word_pools = attribute_sortable(@guess_word_pools)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::GuessWordPoolPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::GuessWordPoolPolicy)
    end

    def guess_word_pool_params
      params.require(:guess_word_pool).permit(
        :subject_id, :title, :description, :published,
        guess_word_questions_attributes: [:id, :word, :description, :_destroy]
      )
    end

    def import_params
      params.require(:file)
    end

    def boolean(param)
      if ActiveModel::Type::Boolean.new.cast(param)
        true
      else
        false
      end
    end
end

