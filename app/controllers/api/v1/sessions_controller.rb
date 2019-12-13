module Api
  module V1
    class SessionsController < ApplicationController

      def create
        user_mail = User.where(email: params[:email]).first
        if !user_mail.nil? && user_mail&.valid_password?(params[:password])
          if user_mail.active == true
            user = {'email': user_mail.email, 'authentication_token': user_mail.authentication_token, 'user_id': user_mail.id, 'error': 'None'}
            companies=[]
            user_customer = UserCustomer.where(user_id: user_mail)

            user_customer.map do |uc|
              if uc.customer.subdomain == 'demo' 
                companies << {'url': uc.customer.url, 'name_company': 'demo1', 'role_id': uc.role_id, 'id': uc.customer.id}
              else
                companies << {'url': uc.customer.url, 'name_company': uc.customer.subdomain, 'role_id': uc.role_id, 'id': uc.customer.id}
              end
            end
            render json: {data: user,'companies': companies }
          else
            render json: {data: {'email': user_mail.email, error:"Usuario Inactivo", code: 401}}
          end
        else
          #head(:unauthorized)
          render json: {data: {'email': params[:email], 'error': "Email o Password Incorrecto", 'code': 401}}
        end
      end
    end
  end
end
