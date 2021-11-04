class CreateUserCards < ActiveRecord::Migration[6.1]
  def change
    create_table :user_cards do |t|
      t.uuid :user_id, null: false
      t.uuid :card_id, null: false

      t.timestamps
    end
  end
end
