class CreateUserCards < ActiveRecord::Migration[6.1]
  def change
    create_table :user_cards do |t|
      t.integer :user_id, null: false
      t.integer :card_id, null: false
      t.boolean :owner, null: false, default: false

      t.timestamps
    end
  end
end
