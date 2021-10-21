class UserCard < ApplicationRecord
  belongs_to :user
  belongs_to :card

  scope :owned, -> { where(owner: :true) }

  validates_presence_of :user_id, :card_id, :owner
end
