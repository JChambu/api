module Api
  module V1
    class UsersController < ApplicationController

      def create
        @user = User.new(user_params)
        if @user.save
          render status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def update_password

        if params[:email].blank? || params[:password].blank?
          return render json: {status: 'E-mail o contraseña vacíos. Por favor, ingresa los datos faltantes e intenta de nuevo.'}
        end

        user = User.find_by(email: params[:email])
        enc_pass = params[:password].to_s.unpack('c*')

        dec = []
        for i in 0..enc_pass.length - 1
          dec[i] = i % 2 == 0 ? enc_pass[i].to_i - 1 : enc_pass[i].to_i + 1
        end
        @dec_pass = dec.pack('c*')

        if user.save_password @dec_pass
          render json: {status: 'La contraseña se actualizó correctamente'}
        else
          render json: {status: 'Ha ocurrido un error, la contraseña no se ha modificado.'}
        end

      end

      private

      def user_update_params
        params.require(:user).permit(:email, :password)
      end

      def user_params
        params.require(:user).permit(:name)
      end

    end
  end
end
