class CreateMunicipalities < ActiveRecord::Migration[6.0]
  def change
    create_table :municipalities do |t|
      t.string :name
      t.string :municipality_key
      t.string :zip_code
      t.integer :state_id
    end
    add_index(:municipalities, :state_id)
  end
end
