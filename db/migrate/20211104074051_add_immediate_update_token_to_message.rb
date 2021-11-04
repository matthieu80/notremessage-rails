class AddImmediateUpdateTokenToMessage < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :immediate_update_token, :string
    add_column :messages, :immediate_update_token_expired_at, :datetime
  end
end
