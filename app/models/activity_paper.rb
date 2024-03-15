class ActivityPaper < ApplicationRecord
  belongs_to :activity
  belongs_to :paper

  validates :paper_id, uniqueness: { scope: :activity_id }
end
