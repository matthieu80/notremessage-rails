require 'rails_helper'

describe 'ConfirmationsController' do
  let!(:user) { create(:user) }
  let(:params) do
    {
      user: {
        email: 'email@email.com'
      }
    }
  end

  describe 'The email confirmation email' do
    it 'has the right subject' do
      mail =  Devise.mailer.deliveries.first
      expect(mail.subject).to eq 'Confirmation instructions'
    end

    it 'contains the right email' do
      mail =  Devise.mailer.deliveries.first
      body = mail.body.raw_source
      expect(body).to include("Welcome #{user.email}!")
    end

    it 'contains a link with correct confirmation_token' do
      mail =  Devise.mailer.deliveries.first
      body = mail.body.raw_source
      confirmation_token = user.confirmation_token
      expect(body).to include("/users/confirmation?confirmation_token=#{confirmation_token}")
    end
  end

  describe 'GET /users/confirmation' do
    describe 'Valid request' do
      it 'confirms the user' do
        expect do
          get "/users/confirmation?confirmation_token=#{user.confirmation_token}", headers: headers
        end.to change { user.reload.confirmed? }.from(false).to(true)
      end

      it 'returns an ok status' do
        get "/users/confirmation?confirmation_token=#{user.confirmation_token}", headers: headers
        expect(response).to have_http_status(:ok)
      end
    end

    describe 'Valid request' do
      it ''do
        get "/users/confirmation?confirmation_token=wrong_token", headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['confirmation_token'].first).to eq 'is invalid'
      end
    end
  end
end
