class Message < ApplicationRecord
  belongs_to :card
  belongs_to :user, optional: true

  validates_presence_of :card_id, :content
  validates_presence_of :user_id, if: Proc.new { |message| !message.name }
  validates_presence_of :name, if: Proc.new { |message| !message.user_id }
end
