FactoryBot.define do
  factory :admin do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    super_admin { true }
  end
end
