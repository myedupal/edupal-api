class Api::V1::Web::CurriculumsController < Api::V1::Web::ApplicationController
  before_action :set_curriculum, only: [:show]
  before_action :set_curriculums, only: [:index]

  def index
    @pagy, @curriculums = pagy(@curriculums)
    render json: @curriculums
  end

  def show
    render json: @curriculum
  end

  private

    def set_curriculum
      @curriculum = Curriculum.find(params[:id])
    end

    def set_curriculums
      @curriculums = Curriculum.preload(:subjects).published
      @curriculums = keyword_queryable(@curriculums)
      @curriculums = attribute_sortable(@curriculums)
    end
end
