class AddPublicIdToCard < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :public_id, :string, null: false
    add_index :cards, :public_id, unique: true
  end
end
