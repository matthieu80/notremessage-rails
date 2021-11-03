require 'rails_helper'

RSpec.describe User, type: :model do

  # associations
  it { should have_many(:user_cards) }
  it { should have_many(:cards) }

  # validations
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:name) }
end
