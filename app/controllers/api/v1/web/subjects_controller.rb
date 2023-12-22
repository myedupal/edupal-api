class Api::V1::Web::SubjectsController < Api::V1::Web::ApplicationController
  before_action :set_subject, only: [:show]
  before_action :set_subjects, only: [:index]

  def index
    @pagy, @subjects = pagy(@subjects)
    render json: @subjects
  end

  def show
    render json: @subject
  end

  private

    def set_subject
      @subject = Subject.find(params[:id])
    end

    def set_subjects
      @subjects = Subject.includes(:curriculum, :papers)
      @subjects = @subjects.where(curriculum_id: params[:curriculum_id]) if params[:curriculum_id].present?
      @subjects = @subjects.where(code: params[:code]) if params[:code].present?
      @subjects = @subjects.where(name: params[:name]) if params[:name].present?
      @subjects = keyword_queryable(@subjects)
      @subjects = attribute_sortable(@subjects)
    end
end
