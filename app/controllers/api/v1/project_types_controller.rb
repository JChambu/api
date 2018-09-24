module Api
  module V1
    class ProjectTypesController < ApplicationController
      #include ActionController::HttpAuthentication::Token::ControllerMethods
      #before_action :authenticate, only: [:index, :create, :destroy]
      before_action :validate_api_key!
      before_action :set_project_type, only: [:show]
      def index
        @project_types = ProjectType.all
        render json: @project_types
      end

      def show
        @project_type = ProjectType.find(params[:id])
        render json: @project_type
      end

      def create
        @project_type = ProjectType.new(project_type_params)
          if @project_type.save
          render json: @project_type, status: :created
        else
          render json: @project_type.errors, status: :unprocessable_entity
      end
      end


      private
      def has_valid_api_key?
        token =  request.headers['X-User-Token']
        email =  request.headers['X-User-Email']
        q= User.where(authentication_token: token, email: email).present?
      end
    
      def validate_api_key!
     
        return head :forbidden unless has_valid_api_key?
      
      end
      
      def authenticate
        authenticate_or_request_with_http_token do |token, options|
          @user = User.find_by(token: X-User-Token)
        end
      end
      def set_project_type
        @project_type = ProjectType.find(params[:id])
      end
      def project_type_params
        params.require(:project_type).permit(:name, {file:[]}, fields_attributes: [:id, :field_type, :name, :required, :cleasing_data, :georeferenced, :regexp_type_id])
      end

    end
  end
end

