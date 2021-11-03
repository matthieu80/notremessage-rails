class MagicLink < ApplicationRecord
  belongs_to :user

  before_create :generate_expired_at, :generate_signature

  validates_presence_of :user

  EXPIRATION_TIME = 24.hours

  private

  def generate_expired_at
    self.expired_at = (Time.now + EXPIRATION_TIME).to_i
  end

  def generate_signature
    self.signature = Digest::SHA2.new(512).hexdigest(
      user.id.to_s +
      user.email +
      self.expired_at.to_s
    )
  end
end
