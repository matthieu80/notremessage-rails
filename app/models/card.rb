class Card < ApplicationRecord
  has_many :user_cards
  has_many :users, through: :user_cards
  has_many :messages

  belongs_to :owner, class_name: 'User'

  validates_presence_of :title, :recipient_name, :owner_id

  before_create :generate_path

  scope :not_deleted, -> { where(deleted_at: nil) }

  def generate_path
    return if path

    self.path = loop do
      path = SecureRandom.urlsafe_base64.first(12).downcase
      break path unless Card.where(path: path).exists?
    end
  end
end
