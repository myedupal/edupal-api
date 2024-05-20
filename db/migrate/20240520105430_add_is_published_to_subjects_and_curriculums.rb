class AddIsPublishedToSubjectsAndCurriculums < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :is_published, :boolean, default: false
    add_column :curriculums, :is_published, :boolean, default: false
  end
end
