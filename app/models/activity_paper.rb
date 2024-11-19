class ActivityPaper < ApplicationRecord
  belongs_to :activity
  belongs_to :paper

  validates :paper, same_organization: { from: :activity }

  validates :paper_id, uniqueness: { scope: :activity_id }
end
