module Api
  module V1
    class SessionsController < ApplicationController

      def create
        user_mail = User.where(email: params[:email]).first
        
        if user_mail&.valid_password?(params[:password])
          user = {'email': user_mail.email, 'authentication_token': user_mail.authentication_token}
          
          companies=[]
          user_customer = UserCustomer.where(user_id: user_mail)

          user_customer.map do |uc|

            companies << {'url': uc.customer.url, 'name_company': uc.customer.subdomain, 'role_id': uc.role_id, 'id': uc.customer.id}
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
