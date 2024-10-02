class Challenge < ApplicationRecord
  belongs_to :subject, optional: true

  has_many :challenge_questions, dependent: :destroy
  has_many :questions, through: :challenge_questions
  has_many :submissions, dependent: :restrict_with_error

  accepts_nested_attributes_for :challenge_questions,
                                allow_destroy: true,
                                reject_if: :reject_challenge_questions?

  enum challenge_type: { daily: 'daily', contest: 'contest', custom: 'custom' }, _default: :daily
  enum reward_type: { binary: 'binary', proportional: 'proportional' }, _default: :binary

  mount_base64_uploader :banner, ImageUploader

  scope :query, ->(keyword) { where('title ILIKE ?', "%#{keyword}%") }
  scope :published, -> { where(is_published: true) }
  scope :with_user_submission_count, lambda { |user_id|
    sql = <<-SQL.squish
      LEFT JOIN (
        SELECT submissions.challenge_id,
               COUNT(submissions.id) AS submission_count
        FROM submissions
        WHERE submissions.user_id = '#{user_id}' AND
              submissions.status = 'submitted'
        GROUP BY submissions.challenge_id
      ) AS user_submission_count ON user_submission_count.challenge_id = challenges.id
    SQL
    joins(sql).select('challenges.*, COALESCE(user_submission_count.submission_count, 0) AS user_submission_count')
  }
  scope :with_user_success_submission_count, lambda { |user_id|
    sql = <<-SQL.squish
      LEFT JOIN (
        SELECT submissions.challenge_id,
               COUNT(submissions.id) AS success_submission_count
        FROM submissions
        WHERE submissions.user_id = '#{user_id}' AND
              submissions.status = 'submitted' AND
              submissions.total_score - submissions.score = 0
        GROUP BY submissions.challenge_id
      ) AS user_success_submission_count ON user_success_submission_count.challenge_id = challenges.id
    SQL
    joins(sql).select('challenges.*, COALESCE(user_success_submission_count.success_submission_count, 0) AS user_success_submission_count')
  }
  scope :with_challenge_questions_count, lambda {
    sql = <<-SQL.squish
      LEFT JOIN (
        SELECT challenge_questions.challenge_id,
                COUNT(challenge_questions.id) AS challenge_questions_count
        FROM challenge_questions
        GROUP BY challenge_questions.challenge_id
      ) AS challenge_questions_count ON challenge_questions_count.challenge_id = challenges.id
    SQL
    joins(sql).select('challenges.*, COALESCE(challenge_questions_count.challenge_questions_count, 0) AS challenge_questions_count')
  }

  scope :ongoing, -> { where(end_at: Time.zone.now...).or(Challenge.where(end_at: nil)) }
  scope :ended, -> { where(end_at: ..Time.zone.now) }

  # validates :title, presence: true
  validates :reward_points, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true, if: -> { contest? }
  validate :date_must_be_unique, if: -> { daily? }

  before_validation :set_title, if: -> { title.blank? }
  before_validation :set_start_at, if: -> { daily? }
  before_validation :set_end_at, if: -> { daily? }
  before_validation :set_custom_start_at, if: -> { custom? && start_at.blank? }

  private

    def reject_challenge_questions?(attributes)
      attributes['question_id'].blank? ||
        attributes['display_order'].blank? ||
        attributes['score'].blank?
    end

    def set_title
      titles = case challenge_type
               when 'daily'
                 [subject&.curriculum&.board, subject&.curriculum&.name, subject&.name, 'Daily Challenge', start_at&.strftime('%d %b %Y')]
               when 'contest'
                 [subject&.curriculum&.board, subject&.curriculum&.name, subject&.name, 'Contest', start_at&.strftime('%d %b %Y')]
               when 'custom'
                 [subject&.curriculum&.board, subject&.curriculum&.name, subject&.name, 'Custom Challenge', start_at&.strftime('%d %b %Y')]
               end
      self.title = titles.compact_blank.join(' ')
    end

    def date_must_be_unique
      return if subject.blank?

      if id.present?
        return unless Challenge.where.not(id: id).exists?(start_at: start_at, subject_id: subject_id)
      else
        return unless Challenge.exists?(start_at: start_at, subject_id: subject_id)
      end

      errors.add(:base, 'there is already a challenge for this date')
    end

    def set_start_at
      self.start_at = start_at&.beginning_of_day
    end

    def set_end_at
      self.end_at = start_at&.end_of_day
    end

    def set_custom_start_at
      self.start_at = Time.zone.now.beginning_of_day
    end
end
