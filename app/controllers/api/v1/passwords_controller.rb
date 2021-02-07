module Api
  module V1
    class PasswordsController < ApplicationController

      # POST /api/v1/passwords/forgot?email=<email>
      def forgot

        if params[:email].blank?
          return render json: {status: 'E-mail vacío. Por favor ingresa tu e-mail e intenta de nuevo.'}
        end

        user = User.find_by(email: params[:email])

        if user.present?
          user.generate_password_token!
          if ENV['MAILER_DOMAIN'].present?
            UserMailer.reset_password_email(user).deliver_now
            render json: {status: 'Se ha enviado un e-mail con las instrucciones para restablecer su contraseña.'}
          else
            render json: {status: 'Mailer domain error. Por favor, comuníquese con el adminsitrador de la aplicación.'}
          end
        else
          render json: {status: 'E-mail no encontrado. Por favor, revisa e intenta de nuevo.'}
        end

      end

    end
  end
end
