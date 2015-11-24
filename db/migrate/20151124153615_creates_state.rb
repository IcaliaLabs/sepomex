class CreatesState < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name, null: false
      t.integer :cities_count, null: false
    end
  end
end
