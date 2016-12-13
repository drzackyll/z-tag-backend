class CreateMarkers < ActiveRecord::Migration[5.0]
  def change
    create_table :markers do |t|
      t.integer :user_id
      t.decimal :lat
      t.decimal :lng
      t.boolean :zombie

      t.timestamps
    end
  end
end
