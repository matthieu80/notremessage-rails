class Card < ApplicationRecord
  has_many :user_cards
  has_many :users, through: :user_cards

  belongs_to :owner, class_name: 'User'

  validates_presence_of :title, :recipient_name, :owner_id

  before_create :generate_public_id

  scope :not_deleted, -> { where(deleted_at: nil) }

  def generate_public_id
    return if public_id

    self.public_id = loop do
      public_id = SecureRandom.urlsafe_base64.first(12).downcase
      break public_id unless Message.where(public_id: public_id).exists?
    end
  end
end
