class Api::V1::Admin::PapersController < Api::V1::Admin::ApplicationController
  before_action :set_paper, only: [:show, :update, :destroy]
  before_action :set_papers, only: [:index]

  def index
    @pagy, @papers = pagy(@papers)
    render json: @papers
  end

  def show
    render json: @paper
  end

  def create
    @paper = pundit_scope(Paper).new(paper_params)
    pundit_authorize(@paper)

    if @paper.save
      render json: @paper
    else
      render json: ErrorResponse.new(@paper), status: :unprocessable_entity
    end
  end

  def update
    if @paper.update(paper_params)
      render json: @paper
    else
      render json: ErrorResponse.new(@paper), status: :unprocessable_entity
    end
  end

  def destroy
    if @paper.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@paper), status: :unprocessable_entity
    end
  end

  private

    def set_paper
      @paper = pundit_scope(Paper).find(params[:id])
      pundit_authorize(@paper) if @paper
    end

    def set_papers
      pundit_authorize(Paper)
      @papers = pundit_scope(Paper.includes(:subject))
      @papers = @papers.joins(:subject).where(subject: { curriculum_id: params[:curriculum_id] }) if params[:curriculum_id].present?
      @papers = @papers.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @papers = attribute_sortable(@papers)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::PaperPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::PaperPolicy)
    end

    def paper_params
      params.require(:paper).permit(:name, :subject_id)
    end
end
