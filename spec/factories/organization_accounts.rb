FactoryBot.define do
  factory :organization_account do
    transient do
      organization { create(:organization) }
    end
    organization_id { organization.id }
    account { create(:admin) }
    role { OrganizationAccount.roles.keys.sample }
  end
end
