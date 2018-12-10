module Api
  module V1
    class SessionsController < ApplicationController

      def create
        user_mail = User.where(email: params[:email]).first
        
        if user_mail&.valid_password?(params[:password])
          user =[]
          user << {'email': user_mail.email}
          user << {'authentication_token': user_mail.authentication_token}

          user_customer = user_mail.customers.all
          user << {'url': user_customer[0].url}
          user << {'name_company': user_customer[0].subdomain}
          render json: {data: user}
        else
          head(:unauthorized)
        end
      end

      def destroy

      end
    end
  end
end
