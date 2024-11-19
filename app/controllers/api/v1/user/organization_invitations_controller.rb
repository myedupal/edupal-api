class Api::V1::User::OrganizationInvitationsController < Api::V1::User::ApplicationController
  before_action :set_organization_invite, only: [:show, :accept, :reject]
  before_action :set_organization_invites, only: [:index, :lookup]

  def index
    @pagy, @organization_invites = pagy(@organization_invites)
    render json: @organization_invites
  end

  def show
    render json: @organization_invite
  end

  def lookup
    @organization_invite = OrganizationInvitation.includes(:organization).where(invite_type: :group_invite).find_code(params.require(:code)).first

    if @organization_invite.present?
      render json: @organization_invite
    else
      render json: { error: 'Invitation code not found' }, status: :not_found
    end
  end

  def accept
    if @organization_invite.accept_invitation!(current_user)
      render json: @organization_invite
    else
      render json: ErrorResponse.new(@organization_invite), status: :unprocessable_entity
    end
  end

  def reject
    if @organization_invite.reject_invitation!(current_user)
      render json: @organization_invite
    else
      render json: ErrorResponse.new(@organization_invite), status: :unprocessable_entity
    end
  end

  private

    def set_organization_invite
      @organization_invite = pundit_scope(
        OrganizationInvitation.includes(:organization)
      ).find(params[:id])
      pundit_authorize(@organization_invite) if @organization_invite
    end

    def set_organization_invites
      pundit_authorize(OrganizationInvitation)
      @organization_invites = pundit_scope(OrganizationInvitation.includes(:organization))
      @organization_invites = if params[:invite_code].present?
                                @organization_invites.find_code(params[:invite_code])
                              else
                                @organization_invites.invitation_for_user(current_user)
                              end

      @organization_invites = @organization_invites.active if params[:active].present? && ActiveSupport::Type::Boolean.new.cast(params[:active])
      @organization_invites = @organization_invites.expired if params[:expired].present? && ActiveSupport::Type::Boolean.new.cast(params[:expired])

    end

    def pundit_scope(scope)
      policy_scope(scope.all, policy_scope_class: Api::V1::User::OrganizationInvitationPolicy::Scope)
    end

    def pundit_authorize(record)
      authorize(record, policy_class: Api::V1::User::OrganizationInvitationPolicy)
    end
end

