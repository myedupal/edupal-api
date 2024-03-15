class ActivityTopic < ApplicationRecord
  belongs_to :activity
  belongs_to :topic

  validates :topic_id, uniqueness: { scope: :activity_id }
end
