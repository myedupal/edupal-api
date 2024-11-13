class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.references :owner, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :title
      t.string :description
      t.string :icon_image
      t.string :banner_image

      t.string :status
      t.integer :current_headcount
      t.integer :maximum_headcount

      t.timestamps
    end

    create_table :organization_accounts, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: { to_table: :organizations }, type: :uuid
      t.references :account, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :role, null: false

      t.index [:organization_id, :account_id], unique: true
      t.timestamps
    end

    add_reference :accounts, :selected_organization, null: true, foreign_key: { to_table: :organizations }, type: :uuid

    reversible do |dir|
      dir.up do
        add_column :accounts, :super_admin, :boolean, null: false, default: false
        Admin.update_all(super_admin: true)
      end

      dir.down do
        Admin.where(super_admin: false).destroy_all
        remove_column :accounts, :super_admin
      end
    end


    create_table :organization_invitations, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: { to_table: :organizations }, type: :uuid
      t.references :account, null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :created_by, null: true, foreign_key: { to_table: :accounts }, type: :uuid
      t.string :email
      t.string :invite_type

      t.string :label
      t.string :invitation_code
      t.integer :used_count, null: false
      t.integer :max_uses, null: false

      t.string :role, null: false

      t.index [:invitation_code], unique: true
      t.index [:organization_id, :account_id], unique: true, where: 'account_id IS NOT NULL', name: 'index_organization_inv_on_org_and_acc'
      t.index [:organization_id, :email], unique: true, where: 'account_id IS NOT NULL', name: 'index_organization_inv_on_org_and_email'
      t.timestamps
    end
  end
end
