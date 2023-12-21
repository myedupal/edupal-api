class Api::V1::Admin::TopicsController < Api::V1::Admin::ApplicationController
  before_action :set_topic, only: [:show, :update, :destroy]
  before_action :set_topics, only: [:index]

  def index
    @pagy, @topics = pagy(@topics)
    render json: @topics
  end

  def show
    render json: @topic
  end

  def create
    @topic = pundit_scope(Topic).new(topic_params)
    pundit_authorize(@topic)

    if @topic.save
      render json: @topic
    else
      render json: ErrorResponse.new(@topic), status: :unprocessable_entity
    end
  end

  def update
    if @topic.update(topic_params)
      render json: @topic
    else
      render json: ErrorResponse.new(@topic), status: :unprocessable_entity
    end
  end

  def destroy
    if @topic.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@topic), status: :unprocessable_entity
    end
  end

  private

    def set_topic
      @topic = pundit_scope(Topic).find(params[:id])
      pundit_authorize(@topic) if @topic
    end

    def set_topics
      pundit_authorize(Topic)
      @topics = pundit_scope(Topic.includes(:subject))
      @topics = @topics.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @topics = keyword_queryable(@topics)
      @topics = attribute_sortable(@topics)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::TopicPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::TopicPolicy)
    end

    def topic_params
      params.require(:topic).permit(:name, :subject_id)
    end
end
