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

    it "is multipart" do
      expect(mail.multipart?).to be true
      expect(mail.parts.length).to eq(2)
      expect(mail.parts.map(&:content_type))
        .to match_array([
                          "text/plain; charset=UTF-8",
                          "text/html; charset=UTF-8"
                        ])
    end

    it "renders the text part" do
      text_part = mail.parts.find { |p| p.content_type.match(/text\/plain/) }
      expect(text_part.body.encoded).to match(/You have been invited to join #{Regexp.quote(organization.title)}/)
      expect(text_part.body.encoded).to match(/Please click the link below to accept your invitation/)
      expect(text_part.body.encoded).to include(invitation.invitation_link)
    end

    it "renders the html part" do
      html_part = mail.parts.find { |p| p.content_type.match(/text\/html/) }
      expect(html_part.body.encoded).to match(/You have been invited to join.*#{Regexp.quote(organization.title)}/)
      expect(html_part.body.encoded).to match(/Please click the button below to accept your invitation/)
      expect(html_part.body.encoded).to include(invitation.invitation_link)
    end
  end
end
