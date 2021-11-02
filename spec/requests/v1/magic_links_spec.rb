require 'rails_helper'

describe 'MagicLinksController' do
  let!(:user) { create(:user) }

  describe 'POST /v1/magic_links' do
    describe 'Valid request' do
      let(:params) do
        { 
          user: {
            email: user.email
          }
        }
      end

      it 'returns ok' do
        post '/v1/magic_links', params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)
      end

      it 'creates a new MagicLink' do
        expect do
          post '/v1/magic_links', params: params.to_json, headers: headers
        end.to change { MagicLink.count }.by(1)
      end

      it 'enqueues mailer job' do
        expect do
          post '/v1/magic_links', params: params.to_json, headers: headers
        end.to have_enqueued_mail(MagicLinkMailer, :magic_link)
      end

      it 'email is sent with correct magic link inside' do
        post '/v1/magic_links', params: params.to_json, headers: headers
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
        post '/v1/magic_links', params: params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to eq 'Email is not present'
      end
    end
  end

  describe 'GET /v1/magic_links' do
    describe '' do
      it '' do
        create(:magic_link, user: user)
      end
    end
  end
end
