require 'rails_helper'

RSpec.describe Message, type: :model do

  # associations
  it { should belong_to(:card) }
  it { should belong_to(:user).optional }

  # validations
  it { should validate_presence_of(:card_id) }
  it { should validate_presence_of(:content) }

  describe '#user_id' do
    let(:card) { create(:user, :with_a_card).cards.first }

    describe 'valid' do
      it 'creates a card with user_id, no name' do
        message = card.messages.create(
          content: 'salut',
          media: nil,
          user_id: card.users.first.id,
          name: nil
        )
        expect(message).to be_valid
        expect(Message.count).to be 1
      end

      it 'updates with a user_id a card that has a name' do
        message = card.messages.create(
          content: 'salut',
          media: nil,
          name: 'Matt'
        )
        message.update(user_id: card.users.first.id)
        expect(message).to be_valid
        expect(Message.last.user_id).to eq card.users.first.id
        expect(Message.last.name).to eq card.users.first.name
      end
    end

    describe 'invalid' do
      it 'needs a user_id or a name' do
        message = card.messages.create(
          content: 'salut',
          media: nil,
          user_id: nil,
          name: nil
        )

        expect(message).to be_invalid
      end
    end
  end

  describe '#name' do
    let(:card) { create(:user, :with_a_card).cards.first }

    describe 'valid' do
      it 'creates a card with no user_id, but a name' do
        message = card.messages.create(
          content: 'salut',
          media: nil,
          user_id: nil,
          name: 'Matt'
        )
        expect(message).to be_valid
        expect(Message.count).to be 1
      end

      it 'updates with a name a card that has a user_id' do
        message = card.messages.create(
          content: 'salut',
          media: nil,
          name: nil,
          user_id: card.users.first.id
        )
        message.update(name: 'Matt')
        expect(message).to be_valid
        expect(Message.last.user_id).to eq card.users.first.id
        expect(Message.last.name).to eq card.users.first.name
      end
    end
  end
end
