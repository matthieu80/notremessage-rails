class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.integer :card_id, null: false
      t.string :content, null: false
      t.string :media
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
