class QuestionImage < ApplicationRecord
  self.implicit_order_column = 'display_order'

  belongs_to :question

  mount_base64_uploader :image, ImageUploader

  validates :image, presence: true
end
