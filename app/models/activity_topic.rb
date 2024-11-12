class ActivityTopic < ApplicationRecord
  belongs_to :activity
  belongs_to :topic

  validates :activity, same_organization: { from: :topic }
  validates :topic_id, uniqueness: { scope: :activity_id }
end
