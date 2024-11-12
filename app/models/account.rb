class Account < ApplicationRecord
  include NanoidGenerator
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable

  validates :oauth2_provider, inclusion: { in: %w[google] }, allow_nil: true
  validates :oauth2_sub, presence: true, if: -> { oauth2_provider.present? }

  has_many :sessions, dependent: :destroy
  has_many :point_activities, dependent: :destroy

  has_many :owned_organizations, class_name: 'Organization', foreign_key: :owner_id, dependent: :restrict_with_error
  belongs_to :selected_organization, class_name: 'Organization', optional: true
  has_many :organization_accounts, foreign_key: :account_id, dependent: :destroy
  has_many :organizations, class_name: 'Organization', through: :organization_accounts, source: :organization

  validate :must_be_member_of_selected_organization, if: -> { selected_organization.present? }

  def self.find_or_register_by_oauth(provider, id_token)
    user = find_or_create_by!(email: id_token['email']) do |u|
      u.name = id_token['name']
      u.password = SecureRandom.alphanumeric(128)
      u.oauth2_provider = provider
      u.oauth2_sub = id_token['sub']
      u.oauth2_iss = id_token['iss']
      u.oauth2_aud = id_token['aud']
      u.oauth2_profile_picture_url = id_token['picture']
    end

    return user unless user.active_for_authentication?

    if user.oauth2_provider.blank?
      user.update_columns(
        oauth2_provider: provider,
        oauth2_sub: id_token['sub'],
        oauth2_iss: id_token['iss'],
        oauth2_aud: id_token['aud'],
        oauth2_profile_picture_url: id_token['picture']
      )
    end

    user
  end

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

  private

    def must_be_member_of_selected_organization
      return if is_a?(Admin) && super_admin?
      return if organizations.include?(selected_organization)

      errors.add(:selected_organization, 'must be a member of the selected organization')
    end
end
