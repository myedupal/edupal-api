class Api::V1::User::UserCollectionsController < Api::V1::User::ApplicationController
  before_action :set_user_collection, only: [:show, :update, :destroy]
  before_action :set_user_collections, only: [:index]

  def index
    @pagy, @user_collections = pagy(@user_collections)
    render json: @user_collections, skip_questions: true
  end

  def show
    render json: @user_collection, include: [
      'user_collection_questions.question.subject',
      'user_collection_questions.question.answers',
      'user_collection_questions.question.question_images',
      'user_collection_questions.question.topics'
    ]
  end

  def create
    @user_collection = pundit_scope(UserCollection).new(user_collection_params)
    pundit_authorize(@user)

    if @user_collection.save
      render json: @user_collection, include: [
        'user_collection_questions.question.subject',
        'user_collection_questions.question.answers',
        'user_collection_questions.question.question_images',
        'user_collection_questions.question.topics'
      ]
    else
      render json: ErrorResponse.new(@user_collection), status: :unprocessable_entity
    end
  end

  def update
    if @user_collection.update(user_collection_params)
      render json: @user_collection, include: [
        'user_collection_questions.question.subject',
        'user_collection_questions.question.answers',
        'user_collection_questions.question.question_images',
        'user_collection_questions.question.topics'
      ]
    else
      render json: ErrorResponse.new(@user_collection), status: :unprocessable_entity
    end
  end

  def destroy
    if @user_collection.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@user_collection), status: :unprocessable_entity
    end
  end

  private

    def set_user_collection
      @user_collection = pundit_scope(
        UserCollection.includes(
          user_collection_questions:
            { question: [:subject, :answers, :question_images, :topics] }
        )
      ).find(params[:id])
      pundit_authorize(@user_collection) if @user_collection
    end

    def set_user_collections
      pundit_authorize(UserCollection)
      @user_collections = pundit_scope(UserCollection)
      @user_collections = @user_collections.where(curriculum_id: current_user.selected_curriculum_id) if params[:current_curriculum].present?
      @user_collections = @user_collections.where(curriculum_id: params[:curriculum_id]) if params[:curriculum_id].present?
      @user_collections = @user_collections.where(collection_type: params[:collection_type]) if params[:collection_type].present?
      @user_collections = keyword_queryable(@user_collections)
      @user_collections = attribute_sortable(@user_collections)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::UserCollectionPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::UserCollectionPolicy)
    end

    def user_collection_params
      params.require(:user_collection).permit(
        :curriculum_id, :collection_type, :title, :description,
        user_collection_questions_attributes: [:id, :question_id, :_destroy]
      )
    end
end

