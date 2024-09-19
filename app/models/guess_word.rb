class GuessWord < ApplicationRecord
  belongs_to :subject
  has_many :guess_word_submissions
  attr_accessor :user_guess_word_submissions

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

  scope :with_reports, lambda {
    left_joins(:guess_word_submissions)
      .select('guess_words.*')
      .select('SUM(CASE WHEN guess_word_submissions.completed_at IS NOT NULL THEN 1 ELSE 0 END) as completed_count')
      .select('AVG(guess_word_submissions.guesses_count) FILTER (WHERE guess_word_submissions.completed_at IS NOT NULL) as avg_guesses_count')
      .select('SUM(CASE WHEN guess_word_submissions.status = \'in_progress\' THEN 1 ELSE 0 END) as in_progress_count')
      .select('SUM(CASE WHEN guess_word_submissions.status = \'success\' THEN 1 ELSE 0 END) as success_count')
      .select('SUM(CASE WHEN guess_word_submissions.status = \'expired\' THEN 1 ELSE 0 END) as expired_count')
      .select('SUM(CASE WHEN guess_word_submissions.status = \'failed\' THEN 1 ELSE 0 END) as failed_count')
      .group('guess_words.id')
  }

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
