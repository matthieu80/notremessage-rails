class CreateMagicLinks < ActiveRecord::Migration[6.1]
  def change
    create_table :magic_links do |t|
      t.integer :user_id, null: false
      t.integer :expired_at, null: false
      t.string :signature, null: false

      t.index :signature, unique: true

      t.timestamps
    end
  end
end
