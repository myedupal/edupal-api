class ChangeQuestionsNumberToInteger < ActiveRecord::Migration[7.0]
  def up
    change_column :questions, :number, :integer, using: 'number::integer'
  end

  def down
    change_column :questions, :number, :string
  end
end
