require 'rails_helper'

describe 'UsersController' do
  describe 'POST /v1/messages' do
    # valid
      #user is authenticated
      #user is not authenticated
    # make sure immedate_token is present in response

    # invalid
      # card is deleted
      # missing attributes
  end

  describe 'PUT /v1/messages/:id' do
    # valid
      # check immediate token when there are no authenticated user
      # authenticated user the message belongs to can update it

    # invalid
      # check immediate token (expired, or wrong token)
      # authenticated user the message belongs to can update it

    # invalid
      # card has been deleted
      # missing attributes
  end

  describe 'DELETE /v1/messages/:id' do
    # valid
      # only card owner can destroy message
    # user not the owner
      # -> message not deleted, returning 401
  end
end
