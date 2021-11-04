class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages, id: :uuid do |t|
      t.uuid :card_id, null: false
      t.string :content, null: false
      t.string :media
      t.uuid :user_id
      t.string :name

      t.timestamps
    end
  end
end
