class Api::V1::Admin::SubjectsController < Api::V1::Admin::ApplicationController
  before_action :set_subject, only: [:show, :update, :destroy]
  before_action :set_subjects, only: [:index]

  def index
    @pagy, @subjects = pagy(@subjects)
    render json: @subjects
  end

  def show
    render json: @subject
  end

  def create
    @subject = pundit_scope(Subject).new(subject_params)
    pundit_authorize(@subject)

    if @subject.save
      render json: @subject
    else
      render json: ErrorResponse.new(@subject), status: :unprocessable_entity
    end
  end

  def update
    if @subject.update(subject_params)
      render json: @subject
    else
      render json: ErrorResponse.new(@subject), status: :unprocessable_entity
    end
  end

  def destroy
    if @subject.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@subject), status: :unprocessable_entity
    end
  end

  private

    def set_subject
      @subject = pundit_scope(Subject).find(params[:id])
      pundit_authorize(@subject) if @subject
    end

    def set_subjects
      pundit_authorize(Subject)
      @subjects = pundit_scope(Subject.includes(:curriculum, :papers))
      @subjects = @subjects.where(curriculum_id: params[:curriculum_id]) if params[:curriculum_id].present?
      @subjects = @subjects.where(code: params[:code]) if params[:code].present?
      @subjects = @subjects.where(name: params[:name]) if params[:name].present?
      @subjects = keyword_queryable(@subjects)
      @subjects = attribute_sortable(@subjects)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::SubjectPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::SubjectPolicy)
    end

    def subject_params
      params.require(:subject).permit(:name, :curriculum_id, :code, :is_published, :banner, :remove_banner)
    end
end
