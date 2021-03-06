class ApplicationController < ActionController::API

  # acts_as_token_authentication_handler_for User, fallback: :exception
  # respond_to :json
  after_action :current_user


  def current_user
    @current_user  = @user
  end

  private

  def has_valid_api_key?
    token = request.headers['X-User-Token']
    email = request.headers['X-User-Email']
    @user = User.where(authentication_token: token, email: email).where(active: true).first
    @user.present?
  end


  def validate_api_key!
    render json: {data: "Usuario Inactivo", code: 401} unless has_valid_api_key?
  end

end
