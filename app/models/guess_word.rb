class GuessWord < ApplicationRecord
  belongs_to :subject
  has_many :guess_word_submissions

  validates :answer, presence: true
  validates :attempts, presence: true
  validates :reward_points, presence: true
  validates :start_at, presence: true
  validate :end_at_must_be_after_start_at

  before_save :downcase_word

  scope :query, ->(keyword) { where('answer ILIKE :keyword', keyword: "%#{keyword}%") }
  scope :ongoing, -> { where(start_at: ..Time.now).where('COALESCE(end_at, :future) >= :now', now: Time.now, future: 1.day.from_now) }
  scope :ended, -> { where(end_at: ..Time.now) }
  scope :only_submitted_by_user, ->(user) { includes(:guess_word_submissions).where(guess_word_submissions: { user: user }) }
  scope :only_unsubmitted_by_user, ->(user) { includes(:guess_word_submissions).where.not(guess_word_submissions: { user: user }).or(GuessWordSubmission.where(user: nil)) }
  scope :only_completed_by_user, ->(user) { only_submitted_by_user(user).where.not(guess_word_submissions: { completed_at: nil }) }
  scope :only_incomplete_by_user, ->(user) { only_submitted_by_user(user).where(guess_word_submissions: { completed_at: nil }) }
  scope :only_available_for_user, ->(user) { only_unsubmitted_by_user(user).or(GuessWord.where(guess_word_submissions: { user: user, completed_at: nil })) }

  private

    def downcase_word
      answer.downcase!
    end

    def end_at_must_be_after_start_at
      return unless start_at && end_at
      return if end_at > start_at

      errors.add(:end_at, 'must be after start_at')
    end
end
