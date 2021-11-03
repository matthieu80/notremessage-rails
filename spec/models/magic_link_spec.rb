require 'rails_helper'

RSpec.describe MagicLink, type: :model do
  # associations
  it { should belong_to(:user) }

  # validations
  it { should validate_presence_of(:user) }
end
