# Preview all emails at http://localhost:3000/rails/mailers/account
class AccountPreview < ActionMailer::Preview
  def invitation_email
    invitation =
      FactoryBot.build(:organization_invitation, :user_invite,
                       account: FactoryBot.build(:user))
    AccountMailer.with(
      user: invitation.account,
      email: invitation.account.email,
      organization: invitation.organization,
      invitation: invitation
    ).invitation_email
  end
end
