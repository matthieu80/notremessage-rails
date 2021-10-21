class Card < ApplicationRecord
  has_many :user_cards
  has_many :users, through: :user_cards

  validates_presence_of :title, :recipient_name, :recipient_email
end
