require 'rails_helper'

describe 'UsersController' do
  let!(:user) { create(:user, :with_a_card) }

  describe 'GET /v1/users/:id' do
    describe 'Valid requests' do
      it 'returns 200' do
        get_with_jwt_token("/v1/users/#{user.id}", user)
        expect(response).to have_http_status(:ok)
      end

      it 'returns the user object' do
        get_with_jwt_token("/v1/users/#{user.id}", user)
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
      it 'returns 401 when no jwt is present' do
        get  "/v1/users/#{user.id}", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /v1/users/:id' do
    describe 'update name and email' do
      describe 'Valid requests' do
        let(:valid_params) do
          {
            user: {
              name: 'Matt',
              email: 'myotheremail@email.com'
            }
          }
        end

        it 'returns 200' do
          put_with_jwt_token("/v1/users/#{user.id}", user, valid_params.to_json)
          expect(response).to have_http_status(:ok)
        end

        it 'returns the user' do
          put_with_jwt_token("/v1/users/#{user.id}", user, valid_params.to_json)
          json = JSON.parse(response.body)

          expect(json['data']['type']).to eql 'user'
          expect(json['data']['attributes']['email']).to eql valid_params[:user][:email]
          expect(json['data']['attributes']['name']).to eql user.name
          expect(json['data']['attributes']['confirmed']).to eql false
  
          card = user.cards.first
          expect(json['included'].size).to be 1
          expect(json['included'].first['type']).to eql 'card'
          expect(json['included'].first['attributes']['title']).to eql card.title
          expect(json['included'].first['attributes']['recipient_name']).to eql card.recipient_name
          expect(json['included'].first['attributes']['group_name']).to eql card.group_name
        end

        it 'does not change the name' do
          expect do
            put_with_jwt_token("/v1/users/#{user.id}", user, valid_params.to_json)
          end.not_to change { user.reload.name }
        end

        it 'does change the email' do
          expect do
            put_with_jwt_token("/v1/users/#{user.id}", user, valid_params.to_json)
          end.to change { user.reload.email }
        end
      end

      describe 'Invalid requests' do
        let(:invalid_name_params) do
          {
            user: {
              name: '',
              email: 'myotheremail@email.com'
            }
          }
        end

        let(:invalid_email_params) do
          {
            user: {
              name: 'Matt',
              email: 'myotheremail'
            }
          }
        end

        it 'should return the error on name' do
          put_with_jwt_token("/v1/users/#{user.id}", user, invalid_name_params.to_json)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid name'
          expect(json['errors'].first['detail']).to eq "Name can't be blank"
        end

        it 'should return the error on email' do
          put_with_jwt_token("/v1/users/#{user.id}", user, invalid_email_params.to_json)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid email'
          expect(json['errors'].first['detail']).to eq 'Email is invalid'
        end

        it 'should not update the user' do
          expect do
            put_with_jwt_token("/v1/users/#{user.id}", user, invalid_name_params.to_json)
          end.not_to change { user.reload }
        end
      end
    end

    describe 'update password and password_confirmation too' do
      describe 'Valid requests' do

        let(:valid_params) do
          {
            user: {
              name: 'my new name',
              email: 'myotheremail@email.com',
              password: 'new_password',
              password: 'new_password',
            }
          }
        end

        it 'should return 200' do
          put_with_jwt_token("/v1/users/#{user.id}", user, valid_params.to_json)
          expect(response).to have_http_status(:ok)
        end

        it 'should return the user object' do
          put_with_jwt_token("/v1/users/#{user.id}", user, valid_params.to_json)
          json = JSON.parse(response.body)

          expect(json['data']['type']).to eql 'user'
          expect(json['data']['attributes']['email']).to eql valid_params[:user][:email]
          expect(json['data']['attributes']['name']).to eql valid_params[:user][:name]
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
        # password present only
        # password_confirmation present only
        # both present, non-identical
        # password too short

        let(:invalid_password_confirmation_params) do
          {
            user: {
              name: 'my new name',
              email: 'myotheremail@email.com',
              password: 'new_password',
              password_confirmation: '',
            }
          }
        end
  
        let(:invalid_password_params) do
          {
            user: {
              name: 'my new name',
              email: 'myotheremail@email.com',
              password: '',
              password_confirmation: 'new_password',
            }
          }
        end

        let(:non_identical_password_params) do
          {
            user: {
              name: 'my new name',
              email: 'myotheremail@email.com',
              password: 'new_password',
              password_confirmation: 'other_password',
            }
          }
        end

        let(:password_too_short_params) do
          {
            user: {
              name: 'my new name',
              email: 'myotheremail@email.com',
              password: 'abc',
              password_confirmation: 'abc',
            }
          }
        end

        it 'should return an error' do
          put_with_jwt_token("/v1/users/#{user.id}", user, invalid_password_confirmation_params.to_json)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid password_confirmation'
          expect(json['errors'].first['detail']).to eq "Password confirmation doesn't match Password"
        end

        it 'should return an error' do
          put_with_jwt_token("/v1/users/#{user.id}", user, invalid_password_params.to_json)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 2
          expect(json['errors'].first['title']).to eq 'Invalid password'
          expect(json['errors'].first['detail']).to eq "Password can't be blank"
          expect(json['errors'].second['title']).to eq 'Invalid password_confirmation'
          expect(json['errors'].second['detail']).to eq "Password confirmation doesn't match Password"
        end

        it 'should return an error' do
          put_with_jwt_token("/v1/users/#{user.id}", user, non_identical_password_params.to_json)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid password_confirmation'
          expect(json['errors'].first['detail']).to eq "Password confirmation doesn't match Password"
        end

        it 'should return an error' do
          put_with_jwt_token("/v1/users/#{user.id}", user, password_too_short_params.to_json)
          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid password'
          expect(json['errors'].first['detail']).to eq "Password is too short (minimum is 6 characters)"
        end
      end
    end
  end
end
