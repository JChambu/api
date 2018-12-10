module Api
  module V1
    class SessionsController < ApplicationController

      def create
        user_mail = User.where(email: params[:email]).first
        
        if user_mail&.valid_password?(params[:password])
          user = {'email': user_mail.email, 'authentication_token': user_mail.authentication_token}
          
          companies=[]
          user_customer = user_mail.customers.all

          user_customer.map do |uc|

          companies << {'url': uc.url, 'name_company': uc.subdomain}
          end
          
          render json: {data: user,'companies': companies }
        else
          head(:unauthorized)
        end
      end

      def destroy

      end
    end
  end
end
