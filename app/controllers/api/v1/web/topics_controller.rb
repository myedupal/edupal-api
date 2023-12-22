class Api::V1::Web::TopicsController < Api::V1::Web::ApplicationController
  before_action :set_topic, only: [:show]
  before_action :set_topics, only: [:index]

  def index
    @pagy, @topics = pagy(@topics)
    render json: @topics
  end

  def show
    render json: @topic
  end

  private

    def set_topic
      @topic = Topic.find(params[:id])
    end

    def set_topics
      @topics = Topic.includes(:subject)
      @topics = @topics.where(subject_id: params[:subject_id]) if params[:subject_id].present?
      @topics = keyword_queryable(@topics)
      @topics = attribute_sortable(@topics)
    end
end
