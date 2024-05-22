class AddTitleToSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :title, :string
  end
end
