class GuessWordSubmission < ApplicationRecord
  include AASM
  belongs_to :organization, optional: true
  belongs_to :guess_word, counter_cache: true
  belongs_to :user

  has_many :guesses, class_name: 'GuessWordSubmissionGuess', dependent: :destroy, counter_cache: :guesses_count
  has_many :point_activities, as: :activity, dependent: :destroy

  validates :guess_word, same_organization: true
  validates :user_id, uniqueness: { scope: :guess_word_id }

  aasm column: :status, whiny_transitions: false do
    state :in_progress, initial: true
    state :success, :failed, :expired

    event :guess, guard: [:game_started?, :guess_is_same_length?, :guess_is_word?], after: [:update_game_status, :update_user_streak] do
      transitions from: :in_progress, to: :expired,
                  guard: [:game_ended?],
                  after: :set_completed_at
      transitions from: :in_progress, to: :in_progress,
                  guard: [:within_attempts?],
                  after: ->(*args) { add_guess(*args) }
      transitions from: :in_progress, to: :failed,
                  after: :set_completed_at
    end

    event :success do
      transitions from: :in_progress, to: :success,
                  after: [:set_completed_at, :create_guess_word_point_activity]
    end

    event :fail do
      transitions from: :in_progress, to: :failed,
                  after: [:set_completed_at]
    end
  end

  private

    def add_guess(guess)
      guess.downcase!

      guesses.create(guess: guess)
    end

    def update_game_status(guess)
      return unless status == 'in_progress'
      return success! if guess == guess_word.answer

      fail! unless within_attempts?
    end

    def update_user_streak(_guess)
      return if status == 'in_progress'

      return if GuessWordSubmission
                  .where(user: user, completed_at: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day)
                  .where.not(id: id).exists?

      user.increment!(:guess_word_daily_streak)
    end

    def create_guess_word_point_activity
      return unless guess_word.reward_points.positive?

      point_activity = user.point_activities.find_or_initialize_by(
        action_type: PointActivity.action_types[:completed_guess_word],
        activity_id: guess_word_id,
        activity_type: guess_word.class.name
      )

      point_activity.points = guess_word.reward_points
      point_activity.save!
    end

    def set_completed_at
      update!(completed_at: Time.current)
    end

    def game_ended?
      return false unless guess_word.end_at.present?
      return false if guess_word.end_at >= Time.current

      errors.add(:guess_word, 'is ended')
      true
    end

    def within_attempts?
      return true if guess_word.attempts > guesses.count

      errors.add(:guess_word, 'no more attempts left for submission')
      false
    end

    def game_started?
      return true if guess_word.start_at <= Time.current

      # AASM calls a guard multiple times, so we need to check to avoid duplicated errors
      errors.add(:guess_word, 'has not started') unless errors.added?(:guess_word, 'has not started')
      false
    end

    def guess_is_same_length?(guess)
      return true if guess_word.answer.length == guess.length

      errors.add(:guess, 'is not the same length as the answer') unless errors.added?(:guess, 'is not the same length as the answer')
      false
    end

    def guess_is_word?(guess)
      return true if guess == guess_word.answer || GuessWordDictionary.exists?(word: guess.downcase, organization: nil)
      return true if organization.present? && GuessWordDictionary.exists?(word: guess.downcase, organization: organization)
      return true if guess_word.guess_word_pool.present? && guess_word.guess_word_pool.guess_word_questions.exists?(word: guess.downcase)

      errors.add(:guess, 'is not in the dictionary') unless errors.added?(:guess, 'is not in the dictionary')
      false
    end
end
