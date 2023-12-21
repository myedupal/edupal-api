class Api::V1::Admin::ExamsController < Api::V1::Admin::ApplicationController
  before_action :set_exam, only: [:show, :update, :destroy]
  before_action :set_exams, only: [:index]

  def index
    @pagy, @exams = pagy(@exams)
    render json: @exams
  end

  def show
    render json: @exam
  end

  def create
    @exam = pundit_scope(Exam).new(exam_params)
    pundit_authorize(@exam)

    if @exam.save
      render json: @exam
    else
      render json: ErrorResponse.new(@exam), status: :unprocessable_entity
    end
  end

  def update
    if @exam.update(exam_params)
      render json: @exam
    else
      render json: ErrorResponse.new(@exam), status: :unprocessable_entity
    end
  end

  def destroy
    if @exam.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@exam), status: :unprocessable_entity
    end
  end

  private

    def set_exam
      @exam = pundit_scope(Exam).find(params[:id])
      pundit_authorize(@exam) if @exam
    end

    def set_exams
      pundit_authorize(Exam)
      @exams = pundit_scope(Exam.includes({ paper: :subject }))
      @exams = @exams.joins(:paper).where(paper: { subject_id: params[:subject_id] }) if params[:subject_id].present?
      @exams = @exams.where(paper_id: params[:paper_id]) if params[:paper_id].present?
      @exams = @exams.where(year: params[:year]) if params[:year].present?
      @exams = @exams.where(season: params[:season]) if params[:season].present?
      @exams = @exams.where(zone: params[:zone]) if params[:zone].present?
      @exams = @exams.where(level: params[:level]) if params[:level].present?
      @exams = attribute_sortable(@exams)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::ExamPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::ExamPolicy)
    end

    def exam_params
      params.require(:exam).permit(:paper_id, :year, :season, :zone, :level, :file, :marking_scheme)
    end
end
