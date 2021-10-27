class AddGroupNameToCard < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :group_name, :string
  end
end
