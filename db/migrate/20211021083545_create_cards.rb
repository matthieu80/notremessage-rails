class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards do |t|
      t.string :recipient_name, null: false
      t.string :recipient_email
      t.string :title, null: false
      t.string :path, null: false
      t.integer :owner_id, null: false
      t.integer :background, default: 1
      
      t.index :owner_id
      t.index :path

      t.timestamps
    end
  end
end
