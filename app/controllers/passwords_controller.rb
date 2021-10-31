class PasswordsController < Devise::PasswordsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  prepend_before_action :require_no_authentication

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
        head :ok
      else
        set_flash_message!(:notice, :updated_not_active)
        head :ok
      end
      # respond_with resource, location: after_resetting_password_path_for(resource)
      head :ok
    else
      set_minimum_password_length
      # respond_with resource
      head :ok
    end
  end
end
