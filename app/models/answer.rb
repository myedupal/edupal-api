class Answer < ApplicationRecord
  self.implicit_order_column = 'display_order'

  belongs_to :question

  mount_base64_uploader :image, ImageUploader

  validates :text, presence: true, if: -> { question&.mcq? }
  # validates :image, uniqueness: { scope: :question_id }, if: -> { image.present? }

  scope :correct, -> { where(is_correct: true) }
  scope :incorrect, -> { where(is_correct: false) }
end
