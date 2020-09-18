class PasswordsController < ApplicationController


  def edit

    token = params[:token].to_s
    @user = User.find_by(reset_password_token: token)

  end


  def reset

    token = user_params[:reset_password_token].to_s
    @user = User.find_by(reset_password_token: token)
    if @user.present? && @user.password_token_valid?
      if @user.reset_password!(user_params[:password])
        render html: 'La contraseña se ha actualizado correctamente.'
      else
        render html: @user.errors.full_messages
      end
    else
      render html: 'Enlace no válido o caducado. Intenta generar un nuevo enlace.'
    end

  end


  private


  def user_params
    params.require(:user).permit(:reset_password_token, :password)
  end

end
