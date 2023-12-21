class Admin < Account
  devise :database_authenticatable, :validatable

  validates :name, presence: true
end
