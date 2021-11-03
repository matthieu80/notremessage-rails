require 'rails_helper'

RSpec.describe Card, type: :model do
  
  # associations
  it { should have_many(:user_cards) }
  it { should have_many(:users) }
  it { should belong_to(:owner) }
  it { should have_many(:messages) }

  # validations
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:recipient_name) }
  # it { should validate_presence_of(:recipient_email) }
end
