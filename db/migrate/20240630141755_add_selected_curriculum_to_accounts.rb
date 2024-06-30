class AddSelectedCurriculumToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :selected_curriculum, foreign_key: { to_table: :curriculums }, type: :uuid, null: true
  end
end
