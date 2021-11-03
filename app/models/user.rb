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

  has_many :owned_cards, -> { UserCard.owned }, through: :user_cards, source: :card

  validates_presence_of :email, :name
  accepts_nested_attributes_for :cards
end
