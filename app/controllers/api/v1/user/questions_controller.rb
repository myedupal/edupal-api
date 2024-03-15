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
      @questions = pundit_scope(Question.includes(:subject, :exam, :answers, :question_images, :question_topics, :topics))
      @questions = @questions.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @questions = @questions.joins(:exam).where(exam: { paper_id: params[:paper_id] }) if params[:paper_id].present?
      @questions = @questions.joins(:topics).where(topics: { id: params[:topic_id] }) if params[:topic_id].present?
      @questions = @questions.where(exam_id: params[:exam_id]) if params[:exam_id].present?
      @questions = @questions.where(number: params[:number]) if params[:number].present?
      @questions = @questions.joins(:exam).where(exam: { year: params[:year] }) if params[:year].present?
      @questions = @questions.joins(:exam).where(exam: { season: params[:season] }) if params[:season].present?
      @questions = @questions.joins(:exam).where(exam: { zone: params[:zone] }) if params[:zone].present?
      @questions = @questions.joins(:exam).where(exam: { level: params[:level] }) if params[:level].present?
      @questions = @questions.where(question_type: params[:question_type]) if params[:question_type].present?
      @questions = @questions.with_activity_presence(params[:activity_id]) if params[:activity_id].present?
      @questions = topic_sortable(@questions)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::QuestionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::QuestionPolicy)
    end

    def topic_sortable(questions)
      if params[:sort_by] == 'topic' && params[:sort_order].present?
        questions.joins(:topics)
                 .order("topics.display_order #{params[:sort_order] == 'desc' ? 'desc' : 'asc'}")
                 .order("questions.number asc")
      else
        attribute_sortable(questions)
      end
    end
end
