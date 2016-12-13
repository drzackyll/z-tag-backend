class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
      t.boolean :zombie
      t.integer :days_survived, default: 0
      t.integer :humans_infected, default: 0

      t.timestamps
    end
  end
end
