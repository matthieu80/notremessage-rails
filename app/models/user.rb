class User < ApplicationRecord
  has_many :user_cards
  has_many :cards, through: :user_cards

  has_many :owned_cards, -> { UserCard.owned }, through: :user_cards, source: :card

  validates_presence_of :email, :name
end
