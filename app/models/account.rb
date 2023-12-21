class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable

  has_many :sessions, dependent: :destroy

  def active_for_authentication?
    super && active?
  end
end
