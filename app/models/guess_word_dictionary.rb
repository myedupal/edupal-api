class GuessWordDictionary < ApplicationRecord
  validates :word, presence: true, uniqueness: true

  before_validation :downcase_word

  scope :query, ->(keyword) { where('word ILIKE :keyword', keyword: "%#{keyword}%") }

  private

    def downcase_word
      self.word = word&.strip
      self.word = word&.downcase
    end
end
