class Api::V1::Admin::PlansController < Api::V1::Admin::ApplicationController
  before_action :set_plan, only: [:show, :update, :destroy]
  before_action :set_plans, only: [:index]

  def index
    @pagy, @plans = pagy(@plans)
    render json: @plans
  end

  def show
    render json: @plan
  end

  def create
    @plan = pundit_scope(Plan).new(plan_params)
    pundit_authorize(@plan)

    if @plan.save
      render json: @plan
    else
      render json: ErrorResponse.new(@plan), status: :unprocessable_entity
    end
  end

  def update
    if @plan.update(plan_params)
      render json: @plan
    else
      render json: ErrorResponse.new(@plan), status: :unprocessable_entity
    end
  end

  def destroy
    if @plan.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@plan), status: :unprocessable_entity
    end
  end

  private

    def set_plan
      @plan = pundit_scope(Plan).find(params[:id])
      pundit_authorize(@plan) if @plan
    end

    def set_plans
      pundit_authorize(Plan)
      @plans = pundit_scope(Plan.includes(:prices))
      @plans = attribute_sortable(@plans)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::PlanPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::PlanPolicy)
    end

    def plan_params
      params.require(:plan).permit(
        :name, :is_published, prices_attributes: [:id, :amount, :amount_currency, :billing_cycle, :_destroy]
      ).tap do |whitelisted|
        all_permitted = params.require(:plan).permit!
        whitelisted[:limits] = all_permitted[:limits] if all_permitted[:limits]
      end
    end
end
