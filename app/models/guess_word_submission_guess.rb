class GuessWordSubmissionGuess < ApplicationRecord
  belongs_to :guess_word_submission, counter_cache: :guesses_count
  has_one :guess_word, through: :guess_word_submission
  has_one :user, through: :guess_word_submission

  validates :guess, presence: true
  validates :result, presence: true

  before_validation :set_result, if: -> { guess.present? }

  private

    def set_result
      # create a result of the user's guess
      # if the word is "shape" and the guess is "asset", it will return [include, include, exclude, include, exclude]
      # the second s will return "exclude" because the word only have one "s"
      # answer_char map facilitate showing duplicates by subtracting the count everytime a "include" result is given

      guess_result = []
      answer_char_map = {}
      answer_char_map.default = 0
      answer = guess_word.answer
      answer.chars.each do |letter|
        answer_char_map[letter] += 1
      end

      guess.chars.each_with_index do |letter, index|
        if answer[index] == letter
          guess_result << 'correct'
        elsif (answer_char_map[letter]).positive?
          guess_result << 'include'
          answer_char_map[letter] -= 1
        else
          guess_result << 'exclude'
        end
      end
      self.result = guess_result
    end
end
