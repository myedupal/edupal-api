class Api::V1::Admin::OrganizationsController < Api::V1::Admin::ApplicationController
  before_action :set_organization, only: [:show, :update, :destroy, :leave]
  before_action :set_organizations, only: [:index]

  def index
    @pagy, @organizations = pagy(@organizations)
    render json: @organizations
  end

  def show
    render json: @organization
  end

  def create
    # This will be admin only
    @organization = pundit_scope(Organization).new(organization_params)
    pundit_authorize(@organization)

    if @organization.save
      render json: @organization
    else
      render json: ErrorResponse.new(@organization), status: :unprocessable_entity
    end
  end

  def setup
    @organization = pundit_scope(Organization).new(organization_setup_params)
    @organization.owner = current_admin
    pundit_authorize(@organization)

    if @organization.save
      render json: @organization
    else
      render json: ErrorResponse.new(@organization), status: :unprocessable_entity
    end
  end

  def update
    if @organization.update(organization_params)
      render json: @organization
    else
      render json: ErrorResponse.new(@organization), status: :unprocessable_entity
    end
  end

  def destroy
    if @organization.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@organization), status: :unprocessable_entity
    end
  end

  def leave
    if @organization.leave!(current_admin)
      head :no_content
    else
      render json: ErrorResponse.new(@organization), status: :unprocessable_entity
    end
  end

  private

    def set_organization
      @organization = pundit_scope(Organization).find(params[:id])
      pundit_authorize(@organization) if @organization
    end

    def set_organizations
      pundit_authorize(Organization)
      @organizations = pundit_scope(Organization.includes(:organization_accounts))
      @organizations = keyword_queryable(@organizations)
      @organizations = attribute_sortable(@organizations)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::OrganizationPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::OrganizationPolicy)
    end

    def organization_params
      if current_admin.super_admin?
        params.require(:organization).permit(:owner_id, :title, :description, :icon_image, :icon_banner, :status, :maximum_headcount)
      else
        params.require(:organization).permit(:title, :description, :icon_image, :icon_banner)
      end
    end

    def organization_setup_params
      params.require(:organization).permit(:title, :description, :icon_image, :icon_banner, :maximum_headcount)
    end
end
