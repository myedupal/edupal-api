class Api::V1::User::OrganizationsController < Api::V1::User::ApplicationController
  before_action :set_organization, only: [:show, :leave]
  before_action :set_organizations, only: [:index]

  def index
    @pagy, @organizations = pagy(@organizations)
    render json: @organizations
  end

  def show
    render json: @organization
  end

  def leave
    if @organization.leave!(current_user)
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
      @organizations = pundit_scope(Organization)
      @organizations = keyword_queryable(@organizations)
      @organizations = attribute_sortable(@organizations)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::OrganizationPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::OrganizationPolicy)
    end
end
