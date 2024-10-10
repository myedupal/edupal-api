class AddBannerToSubjects < ActiveRecord::Migration[7.0]
  def change
    add_column :subjects, :banner, :string
    add_column :challenges, :banner, :string
  end
end
