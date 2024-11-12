class UserCollectionQuestion < ApplicationRecord
  belongs_to :user_collection, counter_cache: :questions_count
  belongs_to :question

  validates :question, same_organization: { from: :user_collection }
  validates :question_id, uniqueness: { scope: :user_collection_id, case_sensitive: false }

  validate :must_be_same_curriculum

  def must_be_same_curriculum
    return unless question&.subject.present? && user_collection.present?
    return unless question.subject.curriculum_id != user_collection.curriculum_id

    errors.add(:question, "must be in the same curriculum as the collection")
  end
end
