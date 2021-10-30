class AddPublicIdToMessage < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :public_id, :string, null: false
    add_index :messages, :public_id, unique: true
  end
end
