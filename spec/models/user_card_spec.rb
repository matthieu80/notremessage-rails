require 'rails_helper'

RSpec.describe UserCard, type: :model do
  
  # associations
  it { should belong_to(:card) }
  it { should belong_to(:user) }

  # validations
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:card_id) }
  it { should validate_presence_of(:owner) }
end
