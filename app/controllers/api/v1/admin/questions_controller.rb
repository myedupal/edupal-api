class Api::V1::Admin::QuestionsController < Api::V1::Admin::ApplicationController
  before_action :set_question, only: [:show, :update, :destroy]
  before_action :set_questions, only: [:index]

  def index
    @pagy, @questions = pagy(@questions)
    render json: @questions
  end

  def show
    render json: @question
  end

  def create
    @question = pundit_scope(Question).new(question_params)
    pundit_authorize(@question)

    if @question.save
      render json: @question
    else
      render json: ErrorResponse.new(@question), status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      render json: @question
    else
      render json: ErrorResponse.new(@question), status: :unprocessable_entity
    end
  end

  def destroy
    if @question.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@question), status: :unprocessable_entity
    end
  end

  private

    def set_question
      @question = pundit_scope(Question).find(params[:id])
      pundit_authorize(@question) if @question
    end

    def set_questions
      pundit_authorize(Question)
      @questions = pundit_scope(Question.includes(:subject, :exam, :answers, :question_images, :question_topics, :topics))
      @questions = @questions.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @questions = @questions.joins(:exam).where(exam: { paper_id: params[:paper_id] }) if params[:paper_id].present?
      @questions = @questions.joins(:topics).where(topics: { id: params[:topic_id] }).distinct if params[:topic_id].present?
      @questions = @questions.where(exam_id: params[:exam_id]) if params[:exam_id].present?
      @questions = @questions.where(number: params[:number]) if params[:number].present?
      @questions = @questions.joins(:exam).where(exam: { year: params[:year] }) if params[:year].present?
      @questions = @questions.joins(:exam).where(exam: { season: params[:season] }) if params[:season].present?
      @questions = @questions.joins(:exam).where(exam: { zone: params[:zone] }) if params[:zone].present?
      @questions = @questions.joins(:exam).where(exam: { level: params[:level] }) if params[:level].present?
      @questions = @questions.where(question_type: params[:question_type]) if params[:question_type].present?
      @questions = attribute_sortable(@questions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::QuestionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::QuestionPolicy)
    end

    def question_params
      params.require(:question).permit(
        :exam_id, :number, :question_type, :topics_label, :text,
        answers_attributes: [:id, :text, :image, :_destroy],
        question_images_attributes: [:id, :image, :display_order, :_destroy],
        question_topics_attributes: [:id, :topic_id, :_destroy]
      ).tap do |whitelisted|
        all_permited = params.require(:question).permit!
        whitelisted[:metadata] = all_permited[:metadata] if all_permited[:metadata].present?
      end
    end
end
