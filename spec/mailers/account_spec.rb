require "rails_helper"

RSpec.describe AccountMailer, type: :mailer do
  describe "#invitation_email" do
    let(:user) { instance_double("User", email: "user@example.com", name: "John Doe") }
    let(:organization) { instance_double("Organization", title: "Example Organization") }
    let(:invitation) { instance_double("Invitation", invitation_link: "https://example.com/123456", role: :trainee) }
    let(:email) { "recipient@example.com" }

    subject(:mail) do
      described_class.with(
        user: user,
        email: email,
        organization: organization,
        invitation: invitation
      ).invitation_email
    end

    it "renders the headers" do
      expect(mail.subject).to eq("You Have Been Invited to Join #{organization.title}")
      expect(mail.to).to eq([email])
      expect(mail.from).to eq(["Edupals"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/You have been invited to join the organization #{organization.title}/)
      expect(mail.body.encoded).to match(/Please follow the link below to accept your invitation/)
      expect(mail.body.encoded).to include(invitation.invitation_link)
    end
  end
end
