require 'rails_helper'
require 'devise/jwt/test_helpers'

describe 'SessionsController' do
  let!(:user) { create(:user, :with_a_card) }

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

  #
  ## MAGIC LINKS
  #

  describe 'POST /magic_links' do
    describe 'Valid request' do
      let(:params) do
        { 
          user: {
            email: user.email
          }
        }
      end

      it 'returns ok' do
        post "/magic_links", params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
      end

      it 'creates a new MagicLink' do
        expect do
          post "/magic_links", params: params.to_json, headers: headers
        end.to change { MagicLink.count }.by(1)
      end

      it 'enqueues mailer job' do
        expect do
          post "/magic_links", params: params.to_json, headers: headers
        end.to have_enqueued_mail(MagicLinkMailer, :magic_link)
      end

      it 'email is sent with correct magic link inside' do
        post "/magic_links", params: params.to_json, headers: headers
        perform_enqueued_jobs
        mail = ActionMailer::Base.deliveries.last

        expect(mail.subject).to eq 'Magic Link inside'
        expect(mail.body).to include(MagicLink.last.signature)
      end
    end

    describe 'Invalid request' do
      let(:params) do
        { 
          user: {
            email: 'inexistent_email@email.com'
          }
        }
      end

      it 'returns an error' do
        post '/magic_links', params: params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq 'Email is not present'
      end
    end
  end

  describe 'GET /magic_links/verify' do
    describe 'Valid requests' do
      let(:magic_link) { create(:magic_link, user: user) }
      let(:signature) { magic_link.signature }

      it 'should return an Authorization headers' do
        get "/magic_links/verify?signature=#{signature}", headers: headers
        expect(response.headers['Authorization']).not_to be_empty
      end

      it 'should return an Authorization headers starting with Bearer' do
        get "/magic_links/verify?signature=#{signature}", headers: headers
        expect(/^Bearer /.match(response.headers['Authorization'])).not_to be_nil
      end
      
      it 'should return the user with cards' do
        get "/magic_links/verify?signature=#{signature}", headers: headers
        json = JSON.parse(response.body)

        user = magic_link.user

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
      let!(:magic_link) { create(:magic_link, user: user) }
      let(:signature) { magic_link.signature }

      before do
        magic_link.update(expired_at: 1.day.ago.to_i)
      end

      it 'returns error when signature has expired' do
        get "/magic_links/verify?signature=#{signature}", headers: headers
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to eq 'This signature has expired'
      end

      it 'returns error when the signature does not exist' do
        get "/magic_links/verify?signature=wrong_signature", headers: headers
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['error']).to eq 'Problem with signature'
      end
    end
  end
end
