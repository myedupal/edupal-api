class GuessWordPool < ApplicationRecord
  belongs_to :subject
  belongs_to :user, class_name: 'User', optional: true

  has_many :guess_word_questions, counter_cache: :guess_word_questions_count, dependent: :destroy
  has_many :guess_words, dependent: :nullify
  has_one :daily_guess_word, -> { where(start_at: Time.now.beginning_of_day, end_at: Time.now.end_of_day) }, class_name: 'GuessWord'
  accepts_nested_attributes_for :guess_word_questions, allow_destroy: true

  validates :title, presence: true
  validates :user_id, absence: true, if: -> { default_pool? }

  before_validation :set_title

  scope :query, ->(query) { where('title ILIKE ?', "%#{query}%") }
  scope :by_curriculum, ->(curriculum) { joins(:subject).merge(Subject.where(curriculum: curriculum)) }

  private

    def set_title
      if title.blank?
        self.title = %(#{default_pool ? subject.name.capitalize : 'Untitled'} Question Pool)
      end
      self.title = title.strip
    end
end

