class Answer < ApplicationRecord
  belongs_to :question

  mount_base64_uploader :image, ImageUploader

  validates :text, presence: true, if: -> { question&.mcq? }
end
