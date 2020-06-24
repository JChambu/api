class UserMailer < ApplicationMailer

  def reset_password_email(user)
    @user = user
    mail(to: @user.email, subject: 'Solicitud de cambio de contraseña de GWMobile')
  end

  def new_password_email(user)
    @user = user
    mail(to: @user.email, subject: 'Nuevas credenciales')
  end
end
