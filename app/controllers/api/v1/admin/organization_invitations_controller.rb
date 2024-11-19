class Api::V1::Admin::OrganizationInvitationsController < Api::V1::Admin::ApplicationController
  before_action :set_organization_invitation, only: [:show, :update, :destroy]
  before_action :set_organization_invitations, only: [:index]

  def index
    @pagy, @organization_invitations = pagy(@organization_invitations)
    render json: @organization_invitations
  end

  def show
    render json: @organization_invitation
  end

  def create
    @organization_invitation = pundit_scope(OrganizationInvitation).new(organization_invitation_params)
    @organization_invitation.created_by = current_admin
    pundit_authorize(@organization_invitation)

    if @organization_invitation.save
      render json: @organization_invitation
    else
      render json: ErrorResponse.new(@organization_invitation), status: :unprocessable_entity
    end
  end

  def update
    @organization_invitation.assign_attributes(organization_invitation_params)
    # make sure updated record is still following the policy
    pundit_authorize(@organization_invitation)
    if @organization_invitation.save
      render json: @organization_invitation
    else
      render json: ErrorResponse.new(@organization_invitation), status: :unprocessable_entity
    end
  end

  def destroy
    if @organization_invitation.destroy
      head :no_content
    else
      render json: ErrorResponse.new(@organization_invitation), status: :unprocessable_entity
    end
  end

  private

    def set_organization_invitation
      @organization_invitation = pundit_scope(OrganizationInvitation.includes(:created_by, :account)).find(params[:id])
      pundit_authorize(@organization_invitation) if @organization_invitation
    end

    def set_organization_invitations
      pundit_authorize(OrganizationInvitation)
      @organization_invitations = pundit_scope(OrganizationInvitation.includes(:organization, :created_by, :account))
      @organization_invitations = @organization_invitations.active if params[:active].present?
      @organization_invitations = @organization_invitations.expired if params[:expired].present?
      @organization_invitations = @organization_invitations.query_code(params[:code]) if params[:code].present?
      @organization_invitations = @organization_invitations.query_label(params[:label]) if params[:label].present?
      @organization_invitations = @organization_invitations.where(invite_type: params[:invite_type]) if params[:invite_type].present?
      @organization_invitations = @organization_invitations.where(role: params[:role]) if params[:role].present?
      @organization_invitations = @organization_invitations.where(created_by: params[:created_by_id]) if params[:created_by_id].present?

      @organization_invitations = attribute_sortable(@organization_invitations)
    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::Admin::OrganizationInvitationPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::Admin::OrganizationInvitationPolicy)
    end

    def organization_invitation_params
      if current_admin.super_admin?
        params.require(:organization_invitation).permit(:organization_id, :account_id, :email, :invite_type, :label, :invitation_code, :used_count, :max_uses, :role)
      else
        params.require(:organization_invitation).permit(:organization_id, :account_id, :email, :invite_type, :label, :used_count, :max_uses, :role)
      end
    end
end
