class QuestionImage < ApplicationRecord
  belongs_to :question

  mount_base64_uploader :image, ImageUploader

  validates :image, presence: true
end
