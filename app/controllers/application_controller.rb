class ApplicationController < ActionController::API
  #acts_as_token_authentication_handler_for User, fallback: :exception
  #  respond_to :json

private
  def has_valid_api_key?
    token =  request.headers['X-User-Token']
    email =  request.headers['X-User-Email']
    @user = User.where(authentication_token: token, email: email).first
    @user.present?
      
  end

  def validate_api_key!

    return head :forbidden unless has_valid_api_key?
    
    
  end

end
