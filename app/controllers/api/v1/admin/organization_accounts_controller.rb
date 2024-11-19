class Api::V1::Admin::OrganizationAccountsController < Api::V1::Admin::ApplicationController
  before_action :set_organization_account, only: [:show, :update, :destroy]
  before_action :set_organization_accounts, only: [:index]

  def index
    @pagy, @organization_accounts = pagy(@organization_accounts)
    render json: @organization_accounts
  end

  def show
    render json: @organization_account
  end

  def create
    # This will be admin only
    @organization_account = pundit_scope(OrganizationAccount).new(organization_account_params)
    pundit_authorize(@organization_account)

    if @organization_account.save
      render json: @organization_account
    else
      render json: ErrorResponse.new(@organization_account), status: :unprocessable_entity
    end
  end

  def update
    @organization_account.assign_attributes(organization_account_params)
    # make sure updated record is still following the policy
    pundit_authorize(@organization_account)
    if @organization_account.save
      render json: @organization_account
    else
      render json: ErrorResponse.new(@organization_account), status: :unprocessable_entity
    end
  end

  def destroy
    if @organization_account.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@organization_account), status: :unprocessable_entity
    end
  end

  private

    def set_organization_account
      @organization_account = pundit_scope(OrganizationAccount.includes(:account)).find(params[:id])
      pundit_authorize(@organization_account) if @organization_account
    end

    def set_organization_accounts
      pundit_authorize(OrganizationAccount.includes(:account))
      @organization_accounts = pundit_scope(OrganizationAccount.includes(:account))
      @organization_accounts = @organization_accounts.where(organization_id: current_admin.selected_organization) if params[:selected_organization]
      @organization_accounts = @organization_accounts.where(organization_id: params[:organization_id]) if params[:organization_id]
      @organization_accounts = @organization_accounts.where(role: params[:role]) if params[:role]
      @organization_invites = @organization_invites.active if params[:active].present? && ActiveSupport::Type::Boolean.new.cast(params[:active])
      @organization_invites = @organization_invites.expired if params[:expired].present? && ActiveSupport::Type::Boolean.new.cast(params[:expired])

      @organization_accounts = attribute_sortable(@organization_accounts)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::OrganizationAccountPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::OrganizationAccountPolicy)
    end

    def organization_account_params
      if current_admin.super_admin?
        params.require(:organization_account).permit(:organization_id, :account_id, :role)
      else
        params.require(:organization_account).permit(:role)
      end
    end

end
