class Message < ApplicationRecord
  belongs_to :card

  validates_presence_of :card_id, :content
end
