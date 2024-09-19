class UserCollection < ApplicationRecord
  belongs_to :user
  belongs_to :curriculum
  has_many :user_collection_questions, dependent: :destroy
  has_many :questions, through: :user_collection_questions, counter_cache: :questions_count

  enum collection_type: { flashcard: 'flashcard', flagged: 'flagged' }

  accepts_nested_attributes_for :user_collection_questions, allow_destroy: true, reject_if: :all_blank

  validates :title, presence: true

  before_validation :set_title

  scope :query, ->(query) { where('title ILIKE ?', "%#{query}%") }

  private

    def set_title
      return if title.present?

      self.title = if flashcard?
                     'Flashcards'
                   elsif flagged?
                     'Flagged Questions'
                   end
    end
end
