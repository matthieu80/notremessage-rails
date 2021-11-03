module V1
  class CardsController < ApiController
    before_action :authenticate_user!, except: [:show]
    
    # this endpoint is used when card is created from dashboard
    # (as opposed as a card created during signup)
    def create
      card = current_user.cards.new(
        recipient_name: card_params[:recipient_name],
        group_name: card_params[:group_name],
        title: card_params[:title],
        owner_id: current_user.id
      )

      if card.save
        render jsonapi: card, status: :created
      else
        render jsonapi_errors: card.errors, status: :unprocessable_entity
      end
    end

    # dashboard
    def index
      cards = current_user.cards
      render jsonapi: cards, status: :ok
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
        recipient_name: card_params[:recipient_name],
        group_name: card_params[:group_name],
        title: card_params[:title],
      )
      render json: card
    end

    def destroy
      # authorization check for current user
      Card.find_by(public_id: params[:public_id]).destroy
      head :no_content
    end

    def send_by_email
      # check stripe
      # delayed sending?
      # send email
      # create image from the card
    end

    private

    def card_params
      params.require(:card).permit(:recipient_name, :title, :group_name)
    end
  end
end
