class User < Account
  devise :database_authenticatable, :validatable, :registerable

  validates :name, presence: true
end
