class SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?

    render json: {yoyo: 'hihihi'}
  end
end
