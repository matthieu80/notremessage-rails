module V1
  class MessagesController < ApiController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!

    # before_action 
    def create
      # check authorization of current user on card
      message = Message.create(message_params)
      render json: message
    end

    def update
      # check authorization of current user on card
      message = Message.find_by(public_id: params[:public_id])
      message.update(message_params)
      render json: message
    end

    def destroy
      # check authorization of current user on card
      Message.find_by(public_id: params[:public_id]).destroy
      head :no_content
    end

    private

    def message_params
      params.require(:message).permit(:card_id, :content, :media, :user_id, :name)
    end
  end
end
