class Api::V1::Web::PapersController < Api::V1::Web::ApplicationController
  before_action :set_paper, only: [:show]
  before_action :set_papers, only: [:index]

  def index
    @pagy, @papers = pagy(@papers)
    render json: @papers
  end

  def show
    render json: @paper
  end

  private

    def set_paper
      @paper = Paper.find(params[:id])
    end

    def set_papers
      @papers = Paper.includes(:subject, :exams)
      @papers = @papers.joins(:subject).where(subject: { curriculum_id: params[:curriculum_id] }) if params[:curriculum_id].present?
      @papers = @papers.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @papers = attribute_sortable(@papers)
    end
end
