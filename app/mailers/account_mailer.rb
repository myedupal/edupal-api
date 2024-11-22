class AccountMailer < ApplicationMailer

  def invitation_email
    @email = params[:email]
    @user = params[:user]
    @organization = params[:organization]
    @invitation = params[:invitation]
    mail(to: @email, subject: "You Have Been Invited to Join #{@organization.title}")
  end
end
