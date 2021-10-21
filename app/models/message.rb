class Message < ApplicationRecord
  belongs_to :card

  validates_presence_of :card_id, :content

  # necessary?
  # validates_presence_of :user_id, if: Proc.new { |message| !message.user_id })
  # validates_presence_of :name, if: Proc.new { |message| !message.name })
end
