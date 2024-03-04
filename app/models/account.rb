class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable

  has_many :sessions, dependent: :destroy
  has_many :point_activities, dependent: :destroy

  def active_for_authentication?
    super && active?
  end
end
