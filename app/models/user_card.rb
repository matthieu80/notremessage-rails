class UserCard < ApplicationRecord
  belongs_to :user
  belongs_to :card

  validates_presence_of :user_id, :card_id
end
