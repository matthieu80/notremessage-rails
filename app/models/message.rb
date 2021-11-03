class Message < ApplicationRecord
  belongs_to :card

  before_create :generate_public_id

  validates_presence_of :card_id, :content
  validates_presence_of :user_id, if: Proc.new { |message| !message.user_id }
  validates_presence_of :name, if: Proc.new { |message| !message.name }

  private

  def generate_public_id
    return if public_id

    self.public_id = loop do
      public_id = SecureRandom.hex(10)
      break public_id unless Message.where(public_id: public_id).exists?
    end
  end
end
