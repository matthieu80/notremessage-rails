class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  before_action :configure_permitted_parameters
  skip_before_action :verify_authenticity_token

  #POST /resource
  def create
    build_resource(sign_up_params)

    # TODO
    # transaction pour user et card if card present
    # return jwt------------ IMPORTANT
    resource.save

    yield resource if block_given?

    if resource.persisted?

      card = Card.create!(
        recipient_name: params[:card][:recipient_name],
        group_name: params[:card][:group_name],
        title: params[:card][:title],
      )
      UserCard.create(card: card, user: resource, owner: true)

      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        render jsonapi: resource,
          include: [:cards],
          fields: { users: [:name, :email] },
          status: :created
      else
        expire_data_after_sign_in!
        render json: {status: 200}
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render jsonapi_errors: resource.errors
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :name, card_attributes: [:recipient_name, :group_name, :title]])
  end
end