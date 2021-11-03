module V1
  class UsersController < ApiController
    before_action :authenticate_user!

    def show
      render jsonapi: current_user,
        include: [:cards],
        fields: { users: [:name, :email] },
        status: :ok
    end

    # try:
    # if @product.update(product_params)
    #   send_price_change_email
    #   redirect_to product_path(@product.id)
    # else
    #   render :edit
    # end

    def update
      if user_params[:password].present? || user_params[:password_confirmation].present?
        current_user.skip_reconfirmation!
        updated = current_user.update(
          name: user_params[:name],
          email: user_params[:email],
          password: user_params[:password],
          password_confirmation: user_params[:password_confirmation]
        )

        if updated
          return_current_user
        else
          render jsonapi_errors: current_user.errors, status: :unprocessable_entity
        end

      else
        current_user.skip_reconfirmation!
        updated = current_user.update(
          name: user_params[:name],
          email: user_params[:email]
        )
        
        if updated
          return_current_user
        else
          render jsonapi_errors: current_user.errors, status: :unprocessable_entity
        end
      end
    end

    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def return_current_user
      render jsonapi: current_user,
        include: [:cards],
        fields: { users: [:name, :email] },
        status: :ok
    end
  end
end