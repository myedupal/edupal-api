class Api::V1::Web::PlansController < Api::V1::Web::ApplicationController
  before_action :set_plans, only: [:index]

  def index
    render json: @plans
  end

  private

    def set_plans
      @plans = Plan.includes(:prices).where(is_published: true)
    end
end
