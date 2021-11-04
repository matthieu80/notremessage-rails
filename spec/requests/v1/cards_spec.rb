require 'rails_helper'

describe 'UsersController' do
  let!(:user) { create(:user, :with_a_card) }
  let!(:other_user) { create(:user, :with_a_card, email: 'otheruser@email.com') }

#
## CREATE
#

  describe 'POST /v1/cards' do
    describe 'Valid requests' do
      let(:valid_params) do
        {
          recipient_name: 'Ben',
          title: 'Bon anniv',
          group_name: 'collegues'
        }
      end

      it 'returns 201' do
        post_with_jwt_token('/v1/cards', user, valid_params.to_json)
        expect(response).to have_http_status(:created)
      end

      it 'returns the card object' do
        post_with_jwt_token('/v1/cards', user, valid_params.to_json)
        json = JSON.parse(response.body)

        p json
        expect(json['data']['id']).to eq Card.last.id.to_s
        expect(json['data']['type']).to eq 'card'
        expect(json['data']['attributes']['title']).to eq 'Bon anniv'
        expect(json['data']['attributes']['recipient_name']).to eq 'Ben'
        expect(json['data']['attributes']['group_name']).to eq 'collegues'
      end

      it 'creates a new card' do
        expect do
          post_with_jwt_token('/v1/cards', user, valid_params.to_json)
        end.to change { Card.count }.by(1)
      end

      it 'allocate the card to the current user' do
        post_with_jwt_token('/v1/cards', user, valid_params.to_json)
        expect(Card.last.owner).to eq user
      end
    end

    describe 'Invalid requests' do
      let(:missing_recipient_params) do
        {
          card: {
            recipient_name: '',
            title: 'my title'
          }
        }
      end

      let(:missing_title_params) do
        {
          card: {
            recipient_name: 'Ben',
            title: ''
          }
        }
      end

      it 'returns 401 when no jwt is present' do
        post "/v1/cards", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end

      it 'should return an error' do
        post_with_jwt_token('/v1/cards', user, missing_recipient_params.to_json)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors'].size).to be 1
        expect(json['errors'].first['title']).to eq 'Invalid recipient_name'
        expect(json['errors'].first['detail']).to eq "Recipient name can't be blank"
      end

      it 'should return an error' do
        post_with_jwt_token('/v1/cards', user, missing_title_params.to_json)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors'].size).to be 1
        expect(json['errors'].first['title']).to eq 'Invalid title'
        expect(json['errors'].first['detail']).to eq "Title can't be blank"
      end
    end
  end

#
## INDEX
#

  describe 'GET /v1/cards' do
    before do
      user.cards.create(title: 'Bon anniv', recipient_name: "Bono", owner: user)
    end

    describe 'Valid requests' do
      it 'should return current user cards' do
        get_with_jwt_token('/v1/cards', user)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data'].size).to be 2
        expect(json['data'].first['type']).to eq 'card'
        expect(json['data'].first['id']).to eq user.cards.first.id.to_s
        expect(json['data'].first['attributes']['title']).to eq user.cards.first.title
        expect(json['data'].first['attributes']['recipient_name']).to eq user.cards.first.recipient_name
        expect(json['data'].second['id']).to eq user.cards.second.id.to_s
        expect(json['data'].second['attributes']['title']).to eq user.cards.second.title
        expect(json['data'].second['attributes']['recipient_name']).to eq user.cards.second.recipient_name
      end

      it 'should not leak other people cards' do
        get_with_jwt_token('/v1/cards', other_user)
        json = JSON.parse(response.body)

        expect(json['data'].size).to be 1
        expect(json['data'].first['type']).to eq 'card'
        expect(json['data'].first['id']).to eq other_user.cards.first.id.to_s
        expect(json['data'].first['attributes']['title']).to eq other_user.cards.first.title
        expect(json['data'].first['attributes']['recipient_name']).to eq other_user.cards.first.recipient_name
      end
    end

    describe 'Invalid requests' do
      it 'returns 401 when no jwt is present' do
        post "/v1/cards", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

#
## SHOW (IMPORTANT NOTE: use `:path` instead of `:id`)
#

  describe 'GET /v1/cards/:id' do
    before do
      create(:message, card: user.cards.first, user_id: user.id)
    end

    it 'shows the card with messages when authenticated' do
      get_with_jwt_token("/v1/cards/#{user.cards.first.path}", user)
      json = JSON.parse(response.body)

      expect(json['included'].size).to be 1
      expect(json['included'].first['type']).to eq 'message'
      expect(json['included'].first['id']).to eq Message.last.id.to_s
      expect(json['included'].first['attributes']['content']).to eq 'helloooo'
      expect(json['included'].first['attributes']['media']).to eq nil
      expect(json['included'].first['attributes']['name']).to eq 'Matt'
    end

    it 'shows the card even when not authenticated' do
      get "/v1/cards/#{user.cards.first.path}", headers: headers
      json = JSON.parse(response.body)

      expect(json['included'].size).to be 1
      expect(json['included'].first['type']).to eq 'message'
      expect(json['included'].first['id']).to eq Message.last.id.to_s
      expect(json['included'].first['attributes']['content']).to eq 'helloooo'
      expect(json['included'].first['attributes']['media']).to eq nil
      expect(json['included'].first['attributes']['name']).to eq 'Matt'
    end
  end

#
## UPDATE
#

  describe 'PUT /v1/cards/:id' do
    before do
      user.cards.create(title: 'Bon anniv', recipient_name: "Bono", owner: user)
    end

    let(:valid_params) do
      {
        card: {
          recipient_name: 'Ben',
          title: 'Super anniversaire',
          group_name: 'collegues'
        }
      }
    end

    describe 'Valid requests' do
      it 'should return the updated object' do
        put_with_jwt_token("/v1/cards/#{user.cards.first.id}", user, valid_params.to_json)
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['data']['attributes']['title']).to eq valid_params[:card][:title]
        expect(json['data']['attributes']['recipient_name']).to eq valid_params[:card][:recipient_name]
        expect(json['data']['attributes']['group_name']).to eq valid_params[:card][:group_name]
      end
    end

    describe 'Invalid requests' do
      # the card does not belong to current user
      # invalid recipient_name
      # invalid title
      let(:missing_recipient_name_params) do
        {
          card: {
            recipient_name: '',
            title: 'Super anniversaire',
            group_name: 'collegues'
          }
        }
      end

      let(:missing_title_params) do
        {
          card: {
            recipient_name: 'Ben',
            title: '',
            group_name: 'collegues'
          }
        }
      end

      it 'should return 404 if card does not belong to current user' do
        put_with_jwt_token("/v1/cards/#{user.cards.first.id}", other_user, valid_params.to_json)
        expect(response).to have_http_status(:not_found)
      end

      it 'should return an error' do
        put_with_jwt_token("/v1/cards/#{user.cards.first.id}", user, missing_recipient_name_params.to_json)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors'].size).to be 1
        expect(json['errors'].first['title']).to eq 'Invalid recipient_name'
        expect(json['errors'].first['detail']).to eq "Recipient name can't be blank"
      end

      it 'should return an error' do
        put_with_jwt_token("/v1/cards/#{user.cards.first.id}", user, missing_title_params.to_json)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors'].size).to be 1
        expect(json['errors'].first['title']).to eq 'Invalid title'
        expect(json['errors'].first['detail']).to eq "Title can't be blank"
      end
    end
  end

#
## DESTROY
#

  # TODO: change so that we use deleted_at column
  describe 'DELETE /v1/cards/:id' do
    describe 'Valid requests' do
      it 'should delete a card' do
        expect do
          delete_with_jwt_token("/v1/cards/#{user.cards.first.id}", user)
        end.to change { Card.count }
      end
    end

    describe 'Invalid requests' do
      it 'should not delete any cards' do
        expect do
          delete_with_jwt_token("/v1/cards/#{user.cards.first.id}", other_user)
        end.not_to change { Card.count }
      end
    end
  end

#
## SEND_BY_EMAIL
#

  describe 'POST /v1/cards/:id/send' do
  end
end
