class Organization < ApplicationRecord
  belongs_to :owner, class_name: 'Admin'

  has_many :organization_accounts, dependent: :destroy
  has_many :accounts, through: :organization_accounts, counter_cache: :current_headcount
  has_many :admins, -> { where(role: :admin) }, class_name: 'Admin', through: :organization_accounts, source: :account
  has_many :trainer, -> { where(role: :trainer) }, class_name: 'Admin', through: :organization_accounts, source: :account
  has_many :trainee, -> { where(role: :trainee) }, class_name: 'User', through: :organization_accounts, source: :account

  has_many :selecting_account, foreign_key: :selected_organization_id, dependent: :nullify, class_name: 'Account'

  has_many :organization_invitations, dependent: :destroy

  has_many :curriculums
  has_many :subjects, through: :curriculums

  mount_base64_uploader :icon_image, ImageUploader
  mount_base64_uploader :banner_image, ImageUploader

  enum status: {
    pending: 'pending',
    active: 'active',
    inactive: 'inactive'
  }, _default: :pending

  after_create :create_owner

  scope :query, ->(query) { where('title ILIKE ?', "%#{query}%") }

  def leave!(user)
    organization_account = organization_accounts.find_by(account: user)
    unless organization_account.present?
      errors.add(:base, 'You are not a member of this organization')
      return false
    end

    if user == owner
      errors.add(:base, 'You cannot leave your own organization')
      return false
    end

    unless organization_account.destroy
      errors.add(:base, "Failed to leave organization: #{organization_account.errors.full_messages.join(', ')}")
      return false
    end

    true
  end

  private

    def create_owner
      organization_accounts.find_or_create_by(account: owner, role: :admin)
    end
end
