class AddDeletedAtToCard < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :deleted_at, :datetime
  end
end
