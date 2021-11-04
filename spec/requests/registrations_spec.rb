require 'rails_helper'

describe 'RegistrationsController' do
  let(:valid_params) do
    {
      user: {
        name: "matt",
        password: "mypassword",
        email: "email@email.com"
      },
      card: {
        title: "my card",
        recipient_name: "joe",
        group_name: "your colleagues"
      },
      with_card: true
    }
  end

  describe '/users' do
    describe 'Valid requests' do
      context 'with with_card set to true' do
        it 'should return an Authorization headers' do
          post '/users', params: valid_params.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end

        it 'returns the user and card' do
          post '/users', params: valid_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['included'].size).to be 1
          expect(json['data']['type']).to eq 'user'
          expect(json['data']['id']).to eq User.last.id
          expect(json['data']['attributes']['email']).to eq User.last.email
          expect(json['included'].first['type']).to eq 'card'
          expect(json['included'].first['attributes']['title']).to eq 'my card'
        end

        it 'should return an Authorization headers' do
          post '/users', params: valid_params.to_json, headers: headers
          expect(response.headers['Authorization']).not_to be_empty
        end

        it 'should return an Authorization headers starting with Bearer' do
          post '/users', params: valid_params.to_json, headers: headers
          expect(/^Bearer /.match(response.headers['Authorization'])).not_to be_nil
        end

        it 'should create the user with a jti attribute non-nil' do
          post '/users', params: valid_params.to_json, headers: headers
          jtw = response.headers['Authorization']
          expect(User.last.jti).not_to be_empty
        end

        it 'should create a card with right attributes' do
          post '/users', params: valid_params.to_json, headers: headers
          created_card = User.last.cards.first

          expect(created_card.title).to eq valid_params[:card][:title]
          expect(created_card.recipient_name).to eq valid_params[:card][:recipient_name]
          expect(created_card.group_name).to eq valid_params[:card][:group_name]
        end
      end

      context 'with with_card set to false' do
        it 'respond with 201' do
          post '/users', params: valid_params.merge({with_card: false}).to_json, headers: headers
          expect(response).to have_http_status(:created)
        end

        it 'returns the user only, no card was created' do
          post '/users', params: valid_params.merge({with_card: false}).to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['data']['type']).to eq 'user'
          expect(json['data']['id']).to eq User.last.id
          expect(json['data']['attributes']['email']).to eq User.last.email
          expect(json['included']).to be nil
        end

        it 'should create a user' do
          expect do
            post '/users', params: valid_params.merge({with_card: false}).to_json, headers: headers
          end.to change { User.count }.by(1)
        end

        it 'should not create a card' do
          expect do
            post '/users', params: valid_params.merge({with_card: false}).to_json, headers: headers
          end.not_to change { Card.count }
        end
      end
    end

    describe 'Invalid requests' do
      context 'Email already exists' do
        before do
          create(:user)
        end

        it 'should return error on already existing email' do
          post '/users', params: valid_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid email'
          expect(json['errors'].first['detail']).to eq 'Email has already been taken'
        end
      end

      context 'Missing user attributes' do
        let(:invalid_params) do
          {
            user: {
              password: "mypassword",
              email: "email@email.com"
            },
            card: {
              title: "my card",
              recipient_name: "joe",
              group_name: "your colleagues"
            },
            with_card: true
          }
        end

        it 'should return unprocessable_entity status' do
          post '/users', params: invalid_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return error with detail' do
          post '/users', params: invalid_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid name'
          expect(json['errors'].first['detail']).to eq "Name can't be blank"
        end
      end
      
      context 'Missing card attributes' do
        let(:invalid_params) do
          {
            user: {
              name: "matt",
              password: "mypassword",
              email: "email@email.com"
            },
            card: {
              recipient_name: "joe",
              group_name: "your colleagues"
            },
            with_card: true
          }
        end

        it 'should return unprocessable_entity status' do
          post '/users', params: invalid_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return error with detail' do
          post '/users', params: invalid_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid title'
          expect(json['errors'].first['detail']).to eq "Title can't be blank"
          expect(User.count).to eq 0
        end

        it 'should not create a new user' do
          post '/users', params: invalid_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(User.count).to eq 0
        end
      end

      context 'Password is too short' do
        let(:invalid_params) do
          {
            user: {
              name: "matt",
              password: "abc",
              email: "email@email.com"
            },
            card: {
              recipient_name: "joe",
              group_name: "your colleagues"
            },
            with_card: true
          }
        end

        it 'should return error on already existing email' do
          post '/users', params: invalid_params.to_json, headers: headers
          json = JSON.parse(response.body)

          expect(json['errors'].size).to be 1
          expect(json['errors'].first['title']).to eq 'Invalid password'
          expect(json['errors'].first['detail']).to eq 'Password is too short (minimum is 6 characters)'
        end
      end
    end
  end
end
