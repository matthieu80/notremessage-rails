1- enable uuid in postgres

class EnableUUID < ActiveRecord::Migration
  def change
    enable_extension 'pgcrypto'
  end
end

2- run migrations
rake db:migrate

3- change migrations for users, cards and messages tables
class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, id: :uuid  do |t| <---------------
      t.string :name
      t.timestamps
    end
  end
end

4- change tables with relationships
class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, id: :uuid  do |t|
      t.string :content
      t.uuid :user_id <-------------------------------
      t.timestamps
    end

    add_index :comments, :user_id
  end
end

5- pour que les futures models utilisent eux aussi uuid, il faut ajouter les lignes suivantes sur:
config/initializers/generators.rb:
Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end

6- Pour que `last` et `first` se comportent normalement, on va devoir aussi ajouter sur les models:
class User < ApplicationRecord
  self.implicit_order_column = "created_at"
  ...
end