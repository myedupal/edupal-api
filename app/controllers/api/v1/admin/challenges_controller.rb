class Api::V1::Admin::ChallengesController < Api::V1::Admin::ApplicationController
  before_action :set_challenge, only: [:show, :update, :destroy]
  before_action :set_challenges, only: [:index]

  def index
    @pagy, @challenges = pagy(@challenges)
    render json: @challenges, include: ['*', 'subject.curriculum', 'questions.exam', 'questions.topics']
  end

  def show
    render json: @challenge, include: ['*', 'subject.curriculum', 'questions.exam', 'questions.topics']
  end

  def create
    @challenge = Challenge.new(challenge_params)
    pundit_authorize(@challenge)

    if @challenge.save
      render json: @challenge, include: ['*', 'subject.curriculum', 'questions.exam', 'questions.topics']
    else
      render json: ErrorResponse.new(@challenge), status: :unprocessable_entity
    end
  end

  def update
    if @challenge.update(challenge_params)
      render json: @challenge, include: ['*', 'subject.curriculum', 'questions.exam', 'questions.topics']
    else
      render json: ErrorResponse.new(@challenge), status: :unprocessable_entity
    end
  end

  def destroy
    if @challenge.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@challenge), status: :unprocessable_entity
    end
  end

  private

    def set_challenge
      @challenge = pundit_scope(Challenge).preload({ challenge_questions: { question: [:exam, :topics] } }).find(params[:id])
      pundit_authorize(@challenge) if @challenge
    end

    def set_challenges
      pundit_authorize(Challenge)
      @challenges = pundit_scope(Challenge).preload({ subject: :curriculum }, :challenge_questions, { questions: [:exam, :topics] })
      @challenges = @challenges.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @challenges = @challenges.where(challenge_type: params[:challenge_type]) if params[:challenge_type].present?
      @challenges = keyword_queryable(@challenges)
      @challenges = attribute_sortable(@challenges)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::ChallengePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::ChallengePolicy)
    end

    def challenge_params
      params.require(:challenge).permit(
        :title, :challenge_type, :start_at, :end_at, :reward_points, :reward_type, :penalty_seconds, :subject_id,
        challenge_questions_attributes: [:id, :question_id, :display_order, :score, :_destroy]
      )
    end
end
