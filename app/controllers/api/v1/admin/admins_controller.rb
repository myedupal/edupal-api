class Api::V1::Admin::AdminsController < Api::V1::Admin::ApplicationController
  before_action :set_admin, only: [:show, :update, :destroy]
  before_action :set_admins, only: [:index]

  def index
    @pagy, @admins = pagy(@admins)
    render json: @admins
  end

  def show
    render json: @admin
  end

  def create
    @admin = pundit_scope(Admin).new(admin_params)
    pundit_authorize(@admin)

    if @admin.save
      render json: @admin
    else
      render json: ErrorResponse.new(@admin), status: :unprocessable_entity
    end
  end

  def update
    if @admin.update(admin_params)
      render json: @admin
    else
      render json: ErrorResponse.new(@admin), status: :unprocessable_entity
    end
  end

  def destroy
    if @admin.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@admin), status: :unprocessable_entity
    end
  end

  private

    def set_admin
      @admin = pundit_scope(Admin).find(params[:id])
      pundit_authorize(@admin) if @admin
    end

    def set_admins
      pundit_authorize(Admin)
      @admins = pundit_scope(Admin.all)
      @admins = keyword_queryable(@admins)
      @admins = attribute_sortable(@admins)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::AdminPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::AdminPolicy)
    end

    def admin_params
      params.require(:admin).permit(:email, :name, :active, :password)
    end
end
