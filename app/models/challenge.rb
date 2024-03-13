class Challenge < ApplicationRecord
  belongs_to :subject, optional: true

  has_many :challenge_questions, dependent: :destroy
  has_many :questions, through: :challenge_questions
  has_many :challenge_submissions, dependent: :restrict_with_error

  accepts_nested_attributes_for :challenge_questions,
                                allow_destroy: true,
                                reject_if: :reject_challenge_questions?

  enum challenge_type: { daily: 'daily', contest: 'contest' }, _default: :daily
  enum reward_type: { binary: 'binary', proportional: 'proportional' }, _default: :binary

  scope :query, ->(keyword) { where('title ILIKE ?', "%#{keyword}%") }

  # validates :title, presence: true
  validates :reward_points, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true, if: -> { contest? }
  validate :date_must_be_unique, if: -> { daily? }

  before_validation :set_title, if: -> { title.blank? }
  before_validation :set_start_at, if: -> { daily? }
  before_validation :set_end_at, if: -> { daily? }

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
               end
      self.title = titles.compact_blank.join(' ')
    end

    def date_must_be_unique
      return if subject.blank?
      return unless Challenge.exists?(start_at: start_at, subject_id: subject_id)

      errors.add(:date, 'there is already a challenge for this date')
    end

    def set_start_at
      self.start_at = start_at&.beginning_of_day
    end

    def set_end_at
      self.end_at = start_at&.end_of_day
    end
end
