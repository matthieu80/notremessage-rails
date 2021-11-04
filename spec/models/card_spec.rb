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

  describe '#generate_path' do
    it 'generates a path on creation' do
      user = create(:user)
      card = Card.create(
        recipient_name: 'Ben',
        group_name: 'collegues',
        title: 'au revoir',
        owner_id: user.id
      )

      expect(card.path).not_to be_nil
    end
  end
end
