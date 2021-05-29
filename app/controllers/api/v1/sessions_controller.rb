module Api
  module V1
    class SessionsController < ApplicationController

      # POST /api/v1/sessions?email=<email>&password=<password>
      def create
        user_mail = User.where(email: params[:email]).first
        if !user_mail.nil?

          # Desencripta la contraseña
          enc_pass = params[:password].to_s.unpack('c*')
          dec = []
          for i in 0..enc_pass.length - 1
            dec[i] = i % 2 == 0 ? enc_pass[i].to_i - 1 : enc_pass[i].to_i + 1
          end
          dec_pass = dec.pack('c*')

          if user_mail&.valid_password?(dec_pass)

            if user_mail.active == true
              user = {'email': user_mail.email, 'authentication_token': user_mail.authentication_token, 'user_id': user_mail.id, 'error': 'none'}
              companies=[]
              user_customer = UserCustomer.where(user_id: user_mail)

              user_customer.map do |uc|

                # Levantamos los usuarios de la corporación
                tenant_users = User
                  .joins(:user_customers)
                  .where(user_customers: {customer_id: uc.customer_id})
                  .order(:name)

                @users = []
                tenant_users.map do |u|
                  @users << {'id': u.id, 'name': u.name}
                end

                # Levantamos las capas de cada corporación
                tenant_name = uc.customer.subdomain
                Apartment::Tenant.switch tenant_name do
                  tenant_layers = Layer.all
                  @layers = []
                  tenant_layers.map do |l|
                    @layers << {'name': l.name, 'layer': l.layer, 'url': l.url}
                  end
                end

                # TODO eliminar validación para corporación demo
                if uc.customer.subdomain == 'demo'
                  companies << { 'url': uc.customer.url, 'name_company': 'demo1', 'role_id': uc.role_id, 'id': uc.customer.id, 'logo': uc.customer.logo, 'layers': @layers, 'users': @users}
                else
                  companies << { 'url': uc.customer.url, 'name_company': uc.customer.subdomain, 'role_id': uc.role_id, 'id': uc.customer.id, 'logo': uc.customer.logo, 'layers': @layers, 'users': @users }
                end
              end
              render json: {data: user,'companies': companies }
            else
              render json: {data: {'email': user_mail.email, error:"Usuario Inactivo", code: 401}}
            end

          else
            render json: {data: {'email': params[:email], 'error': "Contraseña incorrecta", 'code': 401}}
          end
        else
          render json: {data: {'email': params[:email], 'error': "Email Incorrecto", 'code': 401}}
        end
      end
    end
  end
end
