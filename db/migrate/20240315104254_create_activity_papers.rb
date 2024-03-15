class CreateActivityPapers < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_papers, id: :uuid do |t|
      t.references :activity, null: false, foreign_key: true, type: :uuid
      t.references :paper, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :activity_papers, [:activity_id, :paper_id], unique: true
  end
end
