class Api::V1::Admin::CurriculumsController < Api::V1::Admin::ApplicationController
  before_action :set_curriculum, only: [:show, :update, :destroy]
  before_action :set_curriculums, only: [:index]

  def index
    @pagy, @curriculums = pagy(@curriculums)
    render json: @curriculums
  end

  def show
    render json: @curriculum
  end

  def create
    @curriculum = pundit_scope(Curriculum).new(curriculum_params)
    pundit_authorize(@curriculum)

    if @curriculum.save
      render json: @curriculum
    else
      render json: ErrorResponse.new(@curriculum), status: :unprocessable_entity
    end
  end

  def update
    if @curriculum.update(curriculum_params)
      render json: @curriculum
    else
      render json: ErrorResponse.new(@curriculum), status: :unprocessable_entity
    end
  end

  def destroy
    if @curriculum.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@curriculum), status: :unprocessable_entity
    end
  end

  private

    def set_curriculum
      @curriculum = pundit_scope(Curriculum).find(params[:id])
      pundit_authorize(@curriculum) if @curriculum
    end

    def set_curriculums
      pundit_authorize(Curriculum)
      @curriculums = pundit_scope(Curriculum.all)
      @curriculums = keyword_queryable(@curriculums)
      @curriculums = attribute_sortable(@curriculums)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::CurriculumPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::CurriculumPolicy)
    end

    def curriculum_params
      params.require(:curriculum).permit(:name, :board, :display_order, :is_published)
    end
end
