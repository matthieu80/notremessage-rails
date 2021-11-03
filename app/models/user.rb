class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :jwt_authenticatable, jwt_revocation_strategy: self
  # so that session storage is not used
  

  has_many :user_cards
  has_many :cards, through: :user_cards

  validates_presence_of :email, :name
  accepts_nested_attributes_for :cards

  def owned_cards
    cards.where(owner_id: id)
  end
end
