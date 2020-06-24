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
          UserMailer.reset_password_email(user).deliver_now
          render json: {status: 'Se ha enviado un e-mail con las instrucciones para restablecer su contraseña.'}
        else
          render json: {status: 'E-mail no encontrado. Por favor revisa e intenta de nuevo.'}
        end

      end

      # GET /api/v1/passwords/reset?email=<email>&token=<token>
      def reset

        token = params[:token].to_s

        if params[:email].blank?
          return render json: {status: 'Token no encontrado.'}
        end

        user = User.find_by(reset_password_token: token)

        if user.present? && user.password_token_valid?
          if user.reset_password!
            UserMailer.new_password_email(user).deliver_now
            render json: {status: 'OK'}, status: :ok
          else
            render json: {error: user.errors.full_messages}, status: :unprocessable_entity
          end
        else
          render json: {error: ['Enlace no válido o caducado. Intenta generar un nuevo enlace.']}, status: :not_found
        end

      end

    end

  end
end
