class Message < ApplicationRecord
  self.implicit_order_column = "created_at"
  UPDATE_EXPIRATION_TIME = 2.hours
  
  belongs_to :card
  belongs_to :user, optional: true

  validates_presence_of :card_id, :content
  validates_presence_of :user_id, if: Proc.new { |message| !message.name }
  validates_presence_of :name, if: Proc.new { |message| !message.user_id }

  before_create :generate_immediate_update_token, :generate_immediate_update_token_expired_at

  def generate_immediate_update_token
    return if immediate_update_token

    self.immediate_update_token = loop do
      immediate_update_token = SecureRandom.uuid
      break immediate_update_token unless Message.where(immediate_update_token: immediate_update_token).exists?
    end
  end

  def generate_immediate_update_token_expired_at
    self.immediate_update_token_expired_at = UPDATE_EXPIRATION_TIME.from_now
  end
end
