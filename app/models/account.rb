class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable

  validates :oauth2_provider, inclusion: { in: %w[google] }, allow_nil: true
  validates :oauth2_sub, presence: true, if: -> { oauth2_provider.present? }

  has_many :sessions, dependent: :destroy
  has_many :point_activities, dependent: :destroy

  def active_for_authentication?
    super && active?
  end

  def oauth_authenticatable?(provider)
    oauth2_provider.present? && oauth2_provider == provider
  end

  def user_registered_by_message
    if oauth2_provider.present?
      "User was registered by #{oauth2_provider}. Please login with #{oauth2_provider} to continue."
    else
      'User was registered by email. Please login with email and password to continue.'
    end
  end

  def zklogin_salt
    return nil if oauth2_sub.blank?

    ZkloginSaltGenerator.new.generate(oauth2_sub)
  end
end
