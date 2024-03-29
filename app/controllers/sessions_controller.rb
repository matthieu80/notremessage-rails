class SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?

    render jsonapi: resource,
      include: [:cards],
      fields: { users: [:name, :email] },
      status: :created
  end

  def gmail
    existing_user = User.find_by(email: gmail_params[:email])
    if existing_user
      signin_and_render_user(existing_user)
    else
      new_user = User.new(gmail_params.merge({password: SecureRandom.uuid, confirmed_at: Time.now}))
      if new_user.save
        signin_and_render_user(new_user)
      else
        render jsonapi_errors: new_user.errors, status: :unprocessable_entity
      end
    end
  end

  # used when user wants a new magic link, email will be sent
  # only param: email
  def send_magic_link_email
    if user = User.find_by(email: magic_link_params[:email])
      magic_link = MagicLink.create(user: user)
      MagicLinkMailer.magic_link(user.email, magic_link).deliver_later
      head :ok
    else
      render json: {error: "Email is not present"}, status: :unprocessable_entity
    end
  end

  # used when user has clicked on the link in the email
  # we check if the signature is the same than in DB.
  # if so, we dispatch new JWT in headers
  def magic_link_verify
    magic_link = MagicLink.find_by(signature: params[:signature])
    if magic_link
      if Time.at(magic_link.expired_at).future?
        sign_in(User, magic_link.user)
        render jsonapi: magic_link.user,
          include: [:cards],
          fields: { users: [:name, :email] },
          status: :created
      else
        render json: {error: 'This signature has expired'}, status: :unprocessable_entity
      end
    else
      render json: {error: 'Problem with signature'}, status: :unprocessable_entity
    end
  end

  private

  def magic_link_params
    params.require(:user).permit(:email)
  end

  def gmail_params
    params.require(:user).permit(:email, :name)
  end

  def signin_and_render_user(user)
    sign_in(User, user)
    render jsonapi: user,
      include: [:cards],
      fields: { users: [:name, :email] },
      status: :created
  end
end
