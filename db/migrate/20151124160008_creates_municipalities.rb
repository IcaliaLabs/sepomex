class CreatesMunicipalities < ActiveRecord::Migration
  def change
    create_table :municipalities do |t|
      t.string :name, null: false
      t.string :municipality_key, null: false
      t.string :zip_code, null: false
      t.integer :state_id
    end

    add_index(:municipalities, :state_id)
  end
end
