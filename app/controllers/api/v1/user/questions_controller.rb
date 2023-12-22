class Api::V1::User::QuestionsController < Api::V1::User::ApplicationController
  before_action :set_question, only: [:show]
  before_action :set_questions, only: [:index]

  def index
    @pagy, @questions = pagy(@questions)
    render json: @questions
  end

  def show
    render json: @question
  end

  private

    def set_question
      @question = pundit_scope(Question).find(params[:id])
      pundit_authorize(@question) if @question
    end

    def set_questions
      pundit_authorize(Question)
      @questions = pundit_scope(Question.includes(:exam, :answers, :question_images, :question_topics, :topics))
      @questions = @questions.joins(exam: :paper).where(paper: { subject_id: params[:subject_id] }) if params[:subject_id].present?
      @questions = @questions.joins(:exam).where(exam: { paper_id: params[:paper_id] }) if params[:paper_id].present?
      @questions = @questions.joins(:topics).where(topics: { id: params[:topic_id] }).distinct if params[:topic_id].present?
      @questions = @questions.where(exam_id: params[:exam_id]) if params[:exam_id].present?
      @questions = @questions.where(number: params[:number]) if params[:number].present?
      @questions = @questions.where(question_type: params[:question_type]) if params[:question_type].present?
      @questions = attribute_sortable(@questions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::QuestionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::QuestionPolicy)
    end
end