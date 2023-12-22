class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans, id: :uuid do |t|
      t.string :name
      t.jsonb :limits
      t.boolean :is_published
      t.string :stripe_product_id

      t.timestamps
    end
  end
end
