class Session < ApplicationRecord
  belongs_to :account

  has_secure_token :token, length: 128

  def revoke!
    update(revoked_at: Time.now) if revoked_at.nil?
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expired_at.present? && expired_at < Time.current.utc
  end
end
