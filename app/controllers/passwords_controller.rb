class PasswordsController < ApplicationController


  def edit

    token = params[:token].to_s
    @user = User.find_by(reset_password_token: token)
    
  end


  def reset

    token = user_params[:reset_password_token].to_s
    @user = User.find_by(reset_password_token: token)
    if @user.present? && @user.password_token_valid?

      Rails.logger.debug ''
      Rails.logger.debug ' *********** TOKEN VALIDO *********** '
      Rails.logger.debug ''

      if @user.reset_password!(user_params[:password])
        # UserMailer.new_password_email(user).deliver_now
        render json: {status: 'OK'}, status: :ok
      else
        render json: {error: @user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      
      Rails.logger.debug ''
      Rails.logger.debug ' *********** TOKEN NO VALIDO *********** '
      Rails.logger.debug ''

      render json: {error: ['Enlace no válido o caducado. Intenta generar un nuevo enlace.']}, status: :not_found
    end

  end


  private


  def user_params
    params.require(:user).permit(:reset_password_token, :password)
  end

end
