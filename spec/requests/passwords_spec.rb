require 'rails_helper'

describe 'PasswordsController' do
  let!(:user) { create(:user) }

  let(:email_params) do
    {
      user: {
        email: 'email@email.com'
      }
    }
  end

  describe 'POST /users/password (forgotten password link triggers email)' do
    it 'has the right subject' do
      post '/users/password', params: email_params.to_json, headers: headers

      mail =  Devise.mailer.deliveries.second # (first is confirmation email)
      expect(mail.subject).to eq 'Reset password instructions'
    end

    it 'contains the right email' do
      post '/users/password', params: email_params.to_json, headers: headers

      mail =  Devise.mailer.deliveries.second
      body = mail.body.raw_source

      expect(body).to include("Hello #{user.email}!")
      expect(body).to include("Someone has requested a link to change your password.")
    end

    it 'contains a link with correct reset_password_token' do
      post '/users/password', params: email_params.to_json, headers: headers

      mail =  Devise.mailer.deliveries.second
      body = mail.body.raw_source
      expect(body).to include("password/edit?reset_password_token=")

      /reset_password_token=(?<reset_password_token>[a-zA-Z0-9_-]*)/ =~ body
      user_from_password_token = User.with_reset_password_token(reset_password_token)
      expect(user).to eq user_from_password_token
    end
  end

  describe 'PUT /users/password' do
    describe 'Valid request' do 
      before do
        post '/users/password', params: email_params.to_json, headers: headers
        mail =  Devise.mailer.deliveries.second # (first is confirmation email)
        body = mail.body.raw_source
        /reset_password_token=(?<reset_password_token>[a-zA-Z0-9_-]*)/ =~ body
        @reset_password_token = reset_password_token

        @params = {
          user: {
            password: 'mypizzaisgood',
            password_confirmation: 'mypizzaisgood',
            reset_password_token: @reset_password_token
          }
        }
      end

      it 'returns the jwt in the authorization header' do
        put "/users/password", params: @params.to_json, headers: headers
        
        expect(response).to have_http_status(:created)
        expect(response.headers['Authorization']).not_to be_empty
        expect(/^Bearer /.match(response.headers['Authorization'])).not_to be_nil
      end
    end


    describe 'Invalid request' do
      let(:params) do
        {
          user: {
            password: 'mypizzaisgood',
            password_confirmation: 'mypizzaisgood',
            reset_password_token: 'wrong_token'
          }
        }
      end

      it 'returns a 422 status and no authorization header' do
        put "/users/password", params: params.to_json, headers: headers
        json = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.headers['Authorization']).to be_nil
      end

      it 'returns an error object' do
        put "/users/password", params: params.to_json, headers: headers
        json = JSON.parse(response.body)

        expect(json['errors'].size).to be 1
        expect(json['errors'].first['title']).to eq 'Invalid reset_password_token'
        expect(json['errors'].first['detail']).to eq 'Reset password token is invalid'
      end
    end
  end
end
