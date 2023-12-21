class Api::V1::Admin::QuestionImagesController < Api::V1::Admin::ApplicationController
  before_action :set_question_image, only: [:show, :update, :destroy]
  before_action :set_question_images, only: [:index]

  def index
    @pagy, @question_images = pagy(@question_images)
    render json: @question_images
  end

  def show
    render json: @question_image
  end

  def create
    @question_image = pundit_scope(QuestionImage).new(question_image_params)
    pundit_authorize(@question_image)

    if @question_image.save
      render json: @question_image
    else
      render json: ErrorResponse.new(@question_image), status: :unprocessable_entity
    end
  end

  def update
    if @question_image.update(question_image_params)
      render json: @question_image
    else
      render json: ErrorResponse.new(@question_image), status: :unprocessable_entity
    end
  end

  def destroy
    if @question_image.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@question_image), status: :unprocessable_entity
    end
  end

  private

    def set_question_image
      @question_image = pundit_scope(QuestionImage).find(params[:id])
      pundit_authorize(@question_image) if @question_image
    end

    def set_question_images
      pundit_authorize(QuestionImage)
      @question_images = pundit_scope(QuestionImage.includes(:question))
      @question_images = @question_images.where(question_id: params[:question_id]) if params[:question_id].present?
      @question_images = attribute_sortable(@question_images)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::QuestionImagePolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::QuestionImagePolicy)
    end

    def question_image_params
      params.require(:question_image).permit(:question_id, :image, :display_order)
    end
end
