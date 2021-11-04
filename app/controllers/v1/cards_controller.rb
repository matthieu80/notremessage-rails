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
      cards = current_user.owned_cards.not_deleted
      render jsonapi: cards, status: :ok
    end

    def show
      card = Card.not_deleted.where(path: params[:path]).first
      unless card
        head(:not_found) and return
       end
      
      render jsonapi: card,
        include: [:messages],
        status: :ok
    end

    def update
      card = current_user.cards.not_deleted.find_by(id: params[:id])
      unless card
       head(:not_found) and return
      end
      if card.update(
        recipient_name: card_params[:recipient_name],
        group_name: card_params[:group_name],
        title: card_params[:title],
      )
        render jsonapi: card,
          include: [:messages],
          status: :ok
      else
        render jsonapi_errors: card.errors, status: :unprocessable_entity
      end
    end

    def destroy
      card = current_user.cards.not_deleted.find_by(id: params[:id])
      card.update(deleted_at: Time.now) if card
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
