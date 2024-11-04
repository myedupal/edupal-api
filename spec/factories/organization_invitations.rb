FactoryBot.define do
  factory :organization_invitation do
    transient do
      organization { create(:organization) }
    end
    organization_id { organization.id }
    # account { }
    # created_by { }
    # email { }
    invite_type { :group_invite }

    label { Faker::Lorem.words(number: 3).join(' ') }
    # invitation_code { }
    used_count { Faker::Number.between(from: 1, to: 10) }
    max_uses { used_count + Faker::Number.between(from: 1, to: 10) }

    role { OrganizationInvitation.roles.keys.sample }

    trait(:user_invite) do
      email { (account.present?) ? nil : Faker::Internet.email }
      invite_type { :user_invite }

      used_count { 0 }
      max_uses { 1 }
    end

    trait(:group_invite) do
      invite_type { :group_invite }

      used_count { 0 }
    end

    trait(:trainee) do
      role { :trainee }
    end

    trait(:trainer) do
      role { :trainer }
    end
  end
end
