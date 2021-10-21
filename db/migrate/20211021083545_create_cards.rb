class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards do |t|
      t.string :recipient_name, null: false
      t.string :recipient_email, null: false
      t.string :title, null: false

      t.timestamps
    end
  end
end
