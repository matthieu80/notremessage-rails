module V1
  class CardsController < ApiController
    before_action :authenticate_user!, except: [:show]
    
    # this endpoint is used when card is created from dashboard
    # (as opposed as a card created during signup)
    def create
      # to put in a transaction
      card = Card.create!(
        recipient_name: params[:card][:recipient_name],
        group_name: params[:card][:group_name],
        title: params[:card][:title],
        owner_id: current_user.id
      )
      UserCard.create!(card: card, user: current_user)

      render json: card
    end

    def show
      # authorization check for current user
      card = Card.find_by(public_id: params[:public_id])
      render json: card
    end

    def update
      # authorization check for current user
      card = Card.find_by(public_id: params[:public_id])
      card = Card.update!(
        recipient_name: params[:card][:recipient_name],
        group_name: params[:card][:group_name],
        title: params[:card][:title],
      )
      render json: card
    end

    def destroy
      # authorization check for current user
      Card.find_by(public_id: params[:public_id]).destroy
      head :no_content
    end

    def send
      # check stripe
      # delayed sending?
      # send email
      # create image from the card
    end
  end
end
