class Api::V1::Web::OrganizationInvitationsController < Api::V1::Web::ApplicationController

  def lookup
    @organization_invite = OrganizationInvitation.includes(:organization).where(invite_type: :group_invite).find_code(params.require(:code)).first

    if @organization_invite.present?
      render json: @organization_invite
    else
      render json: { error: 'Invitation code not found' }, status: :not_found
    end
  end
end

