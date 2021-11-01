require 'rails_helper'
require 'devise/jwt/test_helpers'

describe 'SessionsController' do
  let!(:user) { create(:user) }

  describe '/users/sign_in' do
    describe 'Valid requests' do
      let(:valid_params) do
        {
          user: {
            email: 'email@email.com',
            password: "password"
          }
        }
      end

      it 'should return an Authorization headers' do
        post '/users/sign_in', params: valid_params.to_json, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'should return an Authorization headers' do
        post '/users/sign_in', params: valid_params.to_json, headers: headers
        expect(response.headers['Authorization']).not_to be_empty
      end

      it 'should return an Authorization headers starting with Bearer' do
        post '/users/sign_in', params: valid_params.to_json, headers: headers
        expect(/^Bearer /.match(response.headers['Authorization'])).not_to be_nil
      end

      it 'should return the user' do
        post '/users/sign_in', params: valid_params.to_json, headers: headers
        json = JSON.parse(response.body)

        expect(json['data']['type']).to eql 'user'
        expect(json['data']['attributes']['email']).to eql user.email
        expect(json['data']['attributes']['name']).to eql user.name
        expect(json['data']['attributes']['confirmed']).to eql false

        card = user.cards.first
        expect(json['included'].size).to be 1
        expect(json['included'].first['type']).to eql 'card'
        expect(json['included'].first['attributes']['title']).to eql card.title
        expect(json['included'].first['attributes']['recipient_name']).to eql card.recipient_name
        expect(json['included'].first['attributes']['group_name']).to eql card.group_name
      end
    end

    describe 'Invalid requests' do
      let(:params_wrong_email) do
        {
          user: {
            email: 'email@email.com',
            password: "wrong_password"
          }
        }
      end

      let(:params_wrong_password) do
        {
          user: {
            email: 'email@email.com',
            password: "wrong_password"
          }
        }
      end

      it 'returns an error with unauthorized' do
        post '/users/sign_in', params: params_wrong_email.to_json, headers: headers
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq 'Invalid Email or password.'
      end

      it 'returns an error with unauthorized' do
        post '/users/sign_in', params: params_wrong_password.to_json, headers: headers
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unauthorized)
        expect(json['error']).to eq 'Invalid Email or password.'
      end
    end
  end

  describe '/users/sign_out' do
    let!(:sign_out_headers) do
      headers.merge(Devise::JWT::TestHelpers.auth_headers(headers, user))
    end

    it 'should return 204' do
      delete '/users/sign_out', headers: sign_out_headers
      expect(response).to have_http_status(:no_content)
    end

    it "should change the user's jti attribute" do
      expect do
        delete '/users/sign_out', headers: sign_out_headers
      end.to change { user.reload.jti }
    end
  end
end