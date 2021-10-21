require 'rails_helper'

RSpec.describe Message, type: :model do

  # associations
  it { should belong_to(:card) }

  # validations
  it { should validate_presence_of(:card_id) }
  it { should validate_presence_of(:content) }
end
