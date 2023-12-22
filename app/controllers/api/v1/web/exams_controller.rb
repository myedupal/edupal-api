class Api::V1::Web::ExamsController < Api::V1::Web::ApplicationController
  before_action :set_exam, only: [:show]
  before_action :set_exams, only: [:index]

  def index
    @pagy, @exams = pagy(@exams)
    render json: @exams
  end

  def show
    render json: @exam
  end

  private

    def set_exam
      @exam = Exam.find(params[:id])
    end

    def set_exams
      @exams = Exam.includes({ paper: :subject })
      @exams = @exams.joins(:paper).where(paper: { subject_id: params[:subject_id] }) if params[:subject_id].present?
      @exams = @exams.where(paper_id: params[:paper_id]) if params[:paper_id].present?
      @exams = @exams.where(year: params[:year]) if params[:year].present?
      @exams = @exams.where(season: params[:season]) if params[:season].present?
      @exams = @exams.where(zone: params[:zone]) if params[:zone].present?
      @exams = @exams.where(level: params[:level]) if params[:level].present?
      @exams = attribute_sortable(@exams)
    end
end
