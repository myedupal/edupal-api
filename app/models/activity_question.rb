class ActivityQuestion < ApplicationRecord
  belongs_to :activity, counter_cache: true
  belongs_to :question

  validates :question_id, uniqueness: { scope: :activity_id }
end
