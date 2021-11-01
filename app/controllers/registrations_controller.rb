class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  before_action :configure_permitted_parameters
  skip_before_action :verify_authenticity_token

  #POST /resource
  def create
    build_resource(sign_up_params)
    @card = nil
    create_user_and_card!

    yield resource if block_given?
    
    if resource.persisted? && resource.cards.first
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
      render jsonapi_errors: errors, status: :unprocessable_entity
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :name, card_attributes: [:recipient_name, :group_name, :title]])
  end

  def create_user_and_card!
    User.transaction(requires_new: true) do
      resource.save!
      Card.transaction(requires_new: true) do
        @card = resource.cards.create(
          recipient_name: params[:card][:recipient_name],
          group_name: params[:card][:group_name],
          title: params[:card][:title],
          owner_id: resource.id
        )
      end
      raise ActiveRecord::RecordInvalid unless @card.persisted?
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveRecord::Rollback
    end
  end

  def errors
    if resource.errors.empty?
      @card.errors
    else
      resource.errors
    end
  end
end