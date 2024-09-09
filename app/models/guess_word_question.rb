class GuessWordQuestion < ApplicationRecord
  belongs_to :guess_word_pool, counter_cache: true

  validates :word, presence: true, uniqueness: { scope: :guess_word_pool_id, case_sensitive: false }

  before_validation :downcase_word

  private

    def downcase_word
      self.word = word&.strip
      self.word = word&.downcase
    end
end
