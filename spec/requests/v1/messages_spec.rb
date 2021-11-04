require 'rails_helper'

describe 'UsersController' do
  describe 'POST /v1/messages' do
    let(:user) { create(:user, :with_a_card) }
    let(:valid_with_user_id_params) do
      {
        message: {
          card_id: user.cards.first.id,
          content: 'super message',
          media: nil,
          user_id: user.id,
          name: nil
        }
      }
    end

    let(:valid_with_name_params) do
      {
        message: {
          card_id: user.cards.first.id,
          content: 'super message',
          media: nil,
          user_id: nil,
          name: 'Matt'
        }
      }
    end

    describe 'Valid request' do
      it 'creates immediate_update_token' do
        post '/v1/messages', params: valid_with_name_params.to_json, headers: headers
        expect(Message.last.immediate_update_token).not_to be_nil
      end
      
      context 'user not authenticated' do
        it 'returns 201' do
          post '/v1/messages', params: valid_with_name_params.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end

        it 'creates the message' do
          expect do
            post '/v1/messages', params: valid_with_name_params.to_json, headers: headers
          end.to change { Message.count }.by(1)
        end

        it 'returns the message object' do
          post '/v1/messages', params: valid_with_name_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['data']['id']).to eq Message.last.id
          expect(json['data']['type']).to eq 'message'
          expect(json['data']['attributes']['card_id']).to eq valid_with_name_params[:message][:card_id]
          expect(json['data']['attributes']['content']).to eq valid_with_name_params[:message][:content]
          expect(json['data']['attributes']['name']).to eq valid_with_name_params[:message][:name]
        end
      end

      context 'user authenticated' do
        it 'returns 201' do
          post_with_jwt_token '/v1/messages', user, valid_with_user_id_params.to_json
          expect(response).to have_http_status(:created)
        end

        it 'creates the message' do
          expect do
            post_with_jwt_token '/v1/messages', user, valid_with_user_id_params.to_json
          end.to change { Message.count }.by(1)
        end

        it 'returns the message object' do
          post_with_jwt_token '/v1/messages', user, valid_with_user_id_params.to_json
          json = JSON.parse(response.body)

          expect(json['data']['id']).to eq Message.last.id
          expect(json['data']['type']).to eq 'message'
          expect(json['data']['attributes']['card_id']).to eq valid_with_name_params[:message][:card_id]
          expect(json['data']['attributes']['content']).to eq valid_with_name_params[:message][:content]
          expect(json['data']['attributes']['name']).to eq valid_with_name_params[:message][:name]
        end
      end
    end

    # invalid
      # card is deleted
      # missing attributes
    describe 'Invalid request' do
      let(:missing_content_params) do
        {
          message: {
            card_id: user.cards.first.id,
            content: nil,
            media: nil,
            user_id: nil,
            name: 'Matt'
          }
        }
      end

      let(:missing_user_id_and_name_params) do
        {
          message: {
            card_id: user.cards.first.id,
            content: 'super message',
            media: nil,
            user_id: nil,
            name: nil
          }
        }
      end

      context 'Card was deleted' do
        before { user.cards.first.update(deleted_at: Time.now) }
        it 'returns 404' do
          post '/v1/messages', params: valid_with_name_params.to_json, headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'Missing content param' do
        it 'returns an error' do
          post '/v1/messages', params: missing_content_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid content'
          expect(json['errors'].first['detail']).to eq "Content can't be blank"
        end
      end

      context 'Missing both name and user_id params' do
        it 'returns an error' do
          post '/v1/messages', params: missing_user_id_and_name_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 2
          expect(json['errors'].first['title']).to eq 'Invalid user_id'
          expect(json['errors'].first['detail']).to eq "User can't be blank"
          expect(json['errors'].second['title']).to eq 'Invalid name'
          expect(json['errors'].second['detail']).to eq "Name can't be blank"
        end
      end
    end
  end

  describe 'PUT /v1/messages/:id' do
    let!(:user) { create(:user, :with_a_card) }
    let!(:other_user) { create(:user, :with_a_card, email: 'otheremail@email.com') }
    let(:message) { create(:message, card_id: user.cards.first.id, user: user) }
    let(:valid_with_user_id_params) do
      {
        message: {
          card_id: user.cards.first.id,
          content: 'super message',
          media: nil,
          user_id: user.id,
          name: nil
        }
      }
    end
    let(:valid_with_name_params) do
      {
        message: {
          card_id: user.cards.first.id,
          content: 'super message',
          media: nil,
          user_id: nil,
          name: 'Matt',
          immediate_update_token: message.immediate_update_token
        }
      }
    end

    describe 'Valid request' do
      context 'user not authenticated, but with valid immediate_update_token' do
        it 'returns 200' do
          put "/v1/messages/#{message.id}", params: valid_with_name_params.to_json, headers: headers
          expect(response).to have_http_status(:ok)
        end

        it 'updates the message' do
          expect do
            put "/v1/messages/#{message.id}", params: valid_with_name_params.to_json, headers: headers
          end.to change { message.reload.content }.from('helloooo').to('super message')
        end

        it 'returns the message object' do
          put "/v1/messages/#{message.id}", params: valid_with_name_params.to_json, headers: headers
          json = JSON.parse(response.body)
          
          expect(json['data']['id']).to eq message.id
          expect(json['data']['type']).to eq 'message'
          expect(json['data']['attributes']['card_id']).to eq message.card.id
          expect(json['data']['attributes']['content']).to eq 'super message'
          expect(json['data']['attributes']['name']).to eq 'Matt'
        end
      end

      context 'user authenticated' do
        it 'returns 200' do
          put_with_jwt_token "/v1/messages/#{message.id}", user, valid_with_user_id_params.to_json
          expect(response).to have_http_status(:ok)
        end

        it 'returns the message object' do
          put_with_jwt_token "/v1/messages/#{message.id}", user, valid_with_user_id_params.to_json
          expect(response).to have_http_status(:ok)
          json = JSON.parse(response.body)
          
          expect(json['data']['id']).to eq message.id
          expect(json['data']['type']).to eq 'message'
          expect(json['data']['attributes']['card_id']).to eq message.card.id
          expect(json['data']['attributes']['content']).to eq 'super message'
          expect(json['data']['attributes']['name']).to eq 'Matt'
        end
      end
    end

    describe 'Invalid request' do
      let(:expired_immediate_token_params) do
        {
          message: {
            card_id: user.cards.first.id,
            content: 'super message',
            media: nil,
            user_id: nil,
            name: 'Matt',
            immediate_update_token: message.immediate_update_token
          }
        }
      end

      let(:wrong_immediate_token_params) do
        {
          message: {
            card_id: user.cards.first.id,
            content: 'super message',
            media: nil,
            user_id: nil,
            name: 'Matt',
            immediate_update_token: 'wrong-token'
          }
        }
      end

      context 'user not authenticated' do
        context 'immediate_token has expired' do
          before { message.update(immediate_update_token_expired_at: 1.hour.ago) }

          it 'returns an error 401' do
            put "/v1/messages/#{message.id}", params: expired_immediate_token_params.to_json, headers: headers
            expect(response).to have_http_status(:unauthorized)
          end
        end

        it 'returns error 401 when immediate_token is wrong' do
          put "/v1/messages/#{message.id}", params: wrong_immediate_token_params.to_json, headers: headers
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'user authenticated' do
        it 'returns 401' do
          put_with_jwt_token "/v1/messages/#{message.id}", other_user, wrong_immediate_token_params.to_json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'card was deleted' do
        before { user.cards.first.update(deleted_at: Time.now) }
        it 'returns 404' do
          put "/v1/messages/#{message.id}", params: valid_with_name_params.to_json, headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'missing attributes' do
        let(:missing_message_attributes_params) do
          {
            message: {
              card_id: user.cards.first.id,
              content: nil,
              media: nil,
              user_id: nil,
              name: 'Matt',
              immediate_update_token: message.immediate_update_token
            }
          }
        end

        it 'returns an error' do
          put "/v1/messages/#{message.id}", params: missing_message_attributes_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid content'
          expect(json['errors'].first['detail']).to eq "Content can't be blank"
        end
      end
    end
  end

  describe 'DELETE /v1/messages/:id' do
    let!(:user) { create(:user, :with_a_card) }
    let!(:other_user) { create(:user, :with_a_card, email: 'otheremail@email.com') }
    let(:message) { create(:message, card_id: user.cards.first.id, user: user) }

    describe 'Valid requests' do
      it 'returns 204' do
        delete_with_jwt_token "/v1/messages/#{message.id}", user
        expect(response).to have_http_status(:no_content)
      end

      it 'destroys the message' do
        expect do
          delete_with_jwt_token "/v1/messages/#{message.id}", user
        end.to change { Message.where(id: message.id).count }.from(1).to(0)
      end
    end

    describe 'Invalid requests' do
      it 'returns 204' do
        delete_with_jwt_token "/v1/messages/#{message.id}", other_user
        expect(response).to have_http_status(:unauthorized)
      end

      it '' do
        expect do
          delete_with_jwt_token "/v1/messages/#{message.id}", other_user
        end.not_to change { Message.where(id: message.id).count }
      end
    end
  end
end
