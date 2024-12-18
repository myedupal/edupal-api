class OrganizationInvitation < ApplicationRecord
  belongs_to :organization
  belongs_to :account, optional: true
  belongs_to :created_by, optional: true, class_name: 'Admin'

  enum invite_type: {
    group_invite: 'group_invite',
    user_invite: 'user_invite'
  }, _default: :group_invite

  enum role: {
    admin: 'admin',
    trainer: 'trainer',
    trainee: 'trainee'
  }, _default: :trainee

  validates :used_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_uses, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :invite_type_not_changed

  validate :must_have_either_email_or_account, if: -> { user_invite? }
  validate :must_have_matching_email_and_account, on: :create, if: -> { user_invite? && email.present? && account.present? }
  before_validation :fix_max_uses, if: -> { user_invite? && max_uses > 1 }
  before_validation :resolve_email_to_account, if: -> { email.present? && account.blank? }
  before_validation :downcase_email, if: -> { email.present? }

  validates :account, :email, absence: true, if: -> { group_invite? }
  before_create :set_invitation_code, if: -> { group_invite? && invitation_code.blank? }
  before_validation :set_label, if: -> { label.blank? }

  attr_accessor :send_email

  after_create :send_invitation, if: -> { send_email && user_invite? }

  scope :query_label, ->(keyword) { where("label ILIKE ?", "%#{keyword}%") }
  scope :query_code, ->(keyword) { where("invitation_code ILIKE ?", "%#{keyword.to_s.gsub('-', '').downcase}%") }
  scope :find_code, ->(keyword) { where("invitation_code ILIKE ?", keyword.to_s.gsub('-', '').downcase) }
  scope :invitation_for_user, ->(user) { where("account_id = ?", user.id).or(OrganizationInvitation.where("email = ?", user.email)) }
  scope :active, -> { where("max_uses > used_count") }
  scope :expired, -> { where("max_uses <= used_count") }

  def display_invitation_code
    return nil unless invitation_code.present?

    invitation_code.scan(/.{1,4}/).join('-').upcase
  end

  def accept_invitation!(user)
    if user_invite? && account.present? && account != user
      errors.add(:base, :not_for_current_user, message: 'This invite is not for you')
      return false
    end

    if user_invite? && email.present? && user.email.downcase != email.downcase
      errors.add(:base, :not_for_current_mail, message: 'This invite is not for your email')
      return false
    end

    unless organization.active?
      errors.add(:base, :organization_inactive, message: 'The organization is inactive, please contact your administrator')
      return false
    end

    if organization.accounts.include?(user)
      errors.add(:base, :user_already_joined, message: 'You are already in the organization')
      return false
    end

    if organization.current_headcount >= organization.maximum_headcount
      errors.add(:base, :organization_full, message: 'The organization is full, please contact your administrator')
      return false
    end

    if used_count >= max_uses
      errors.add(:base, :invite_used, message: 'This invite has been exhausted, please contact your administrator')
      return false
    end

    ActiveRecord::Base.transaction(isolation: :serializable) do
      updated_rows = OrganizationInvitation
                       .joins(:organization)
                       .where(id: id)
                       .where('max_uses > used_count')
                       .where('organizations.maximum_headcount > organizations.current_headcount')
                       .update_all('used_count = used_count + 1')

      # make sure model's data are up to date after using update_all
      reload

      if updated_rows.zero?
        if organization.current_headcount >= organization.maximum_headcount
          errors.add(:base, :organization_full, message: 'The organization is full')
        elsif used_count >= max_uses
          errors.add(:base, :invite_used, message: 'This invite has been fully used')
        else
          errors.add(:base, :invite_update_error, message: 'Error accepting this invite, please try again')
        end
        return false
      end

      organization.organization_accounts.create(account: user, role: role)
    end
    true
  end

  def reject_invitation!(user)
    unless user_invite?
      errors.add(:base, 'Only user invite could be rejected')
      return false
    end

    if account.present? && account != user
      errors.add(:base, 'This invite is not for this user')
      return false
    end

    if email.present? && user.email.downcase != email.downcase
      errors.add(:base, 'This invite is not for this email')
      return false
    end

    update(max_uses: 0)

    true
  end

  def invitation_link
    "https://#{Rails.configuration.web_host}/organizations/invitation?id=#{id}"
  end

  private

    def send_invitation
      email = (account.present?) ? account.email : self.email

      AccountMailer.with(
        user: account,
        email: email,
        organization: organization,
        invitation: self
      ).invitation_email.deliver_later
    end

    INVITE_CHARACTER = "0123456789abcdefghijklmnopqrstuvwxyz".freeze
    INVITE_LENGTH = 12
    INVITE_MAX_RETRY = 1000

    def set_invitation_code
      return if invitation_code.present? || account.present?

      INVITE_MAX_RETRY.times do
        self.invitation_code = Nanoid.generate(size: INVITE_LENGTH, alphabet: INVITE_CHARACTER)

        return unless self.class.where(invitation_code: invitation_code).exists?
      end

      raise "Failed to generate a unique invitation code after #{NanoidGenerator::MAX_RETRY} attempts"
    end

    def invite_type_not_changed
      if invite_type_changed? && persisted?
        errors.add(:invite_type, 'Cannot be changed once created')
      end
    end

    def must_have_either_email_or_account
      errors.add(:base, 'Must have either email or account') if account.blank? && email.blank?
    end

    def must_have_matching_email_and_account
      errors.add(:base, 'Email and account must match') if account.email.downcase != email.downcase
    end

    def resolve_email_to_account
      self.account = Account.where(email: email.downcase).first
    end

    def set_label
      if account.present? || email.present?
        email = (account.present?) ? "#{account.email}(#{account.name})" : self.email
        self.label = "Invitation for #{email}"
      else
        self.label = "Group Invitation (#{max_uses})"
      end
    end

    def downcase_email
      email.downcase!
    end

    def fix_max_uses
      self.max_uses = 1 if max_uses > 1
    end
end
