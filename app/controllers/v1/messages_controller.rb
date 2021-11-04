module V1
  class MessagesController < ApiController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!, only: [:destroy]
    before_action :authorize_owner!, only: [:destroy]

    # before_action 
    def create
      card = Card.not_deleted.find_by(id: message_params[:card_id])
      unless card
        head(:not_found) and return
      end

      authenticate_user! if message_params[:user_id]
      message = card.messages.new(message_params)

      if message.save
        render jsonapi: message, status: :created
      else
        render jsonapi_errors: message.errors, status: :unprocessable_entity
      end
    end

    def update
      @message = Message.find_by(id: params[:id])
      unless @message
        head(:not_found) and return
      end

      authenticate_user! if message_params[:user_id]
      unless card_not_deleted
        head(:not_found) and return
      end

      unless authenticated_user_owner_of_message || valid_immediate_token
        head(:unauthorized) and return
      end
      
      if @message.update(message_params)
        render jsonapi: @message, status: :ok
      else
        render jsonapi_errors: @message.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @message.destroy
      head :no_content
    end

    private

    def message_params
      params.require(:message).permit(:card_id, :content, :media, :user_id, :name)
    end

    def update_message_params
      params.require(:message).permit(:card_id, :content, :media, :user_id, :name, :immediate_update_token)
    end

    def card_not_deleted
      @message.card.deleted_at.nil?
    end

    def check_immediate_update_token
      return if message_params[:user_id] && current_user.id == @message.user_id
      unless @message.immediate_update_token == update_message_params[:immediate_update_token] &&
        @message.immediate_update_token_expired_at >= Time.now
        head(:unauthorized) and return
      end
    end

    def authorize_owner!
      @message = Message.find_by(id: params[:id])
      unless @message && @message.card.owner == current_user
        head(:unauthorized) and return
      end
    end

    def authenticated_user_owner_of_message
      message_params[:user_id] && current_user.id == @message.user_id
    end

    def valid_immediate_token
      @message.immediate_update_token == update_message_params[:immediate_update_token] &&
        @message.immediate_update_token_expired_at >= Time.now
    end
  end
end
