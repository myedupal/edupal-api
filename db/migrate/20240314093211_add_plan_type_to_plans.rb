class AddPlanTypeToPlans < ActiveRecord::Migration[7.0]
  def change
    add_column :plans, :plan_type, :string
  end
end
