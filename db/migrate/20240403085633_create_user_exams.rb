class CreateUserExams < ActiveRecord::Migration[7.0]
  def change
    create_table :user_exams, id: :uuid do |t|
      t.string :title
      t.references :created_by, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :subject, null: false, foreign_key: true, type: :uuid
      t.boolean :is_public, null: false, default: false
      t.string :nanoid, null: false

      t.timestamps
    end

    add_index :user_exams, :nanoid, unique: true
  end
end
