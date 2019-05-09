module Api
  module V1
    class ProjectTypesController < ApplicationController
      #include ActionController::HttpAuthentication::Token::ControllerMethods
      #before_action :authenticate, only: [:index, :create, :destroy]
      before_action :validate_api_key!
      before_action :set_project_type, only: [:show]

      def list_projects

        @has_project_types = HasProjectType.where(user_id: @user.id).select(:project_type_id) 
        @p =[]
        @has_project_types.each do |s|
          project_type = ProjectType.where(id: s.project_type_id).first
          show_field = Project.show_data_new(project_type)
          data = {"data":{
            "id":project_type.id, 
            "name":project_type.name,
            "form": show_field
          }
          }
          @p.push(data) 
        end
        render json: @p
      end

      def index

        @has_project_types = HasProjectType.where(user_id: @user.id).select(:project_type_id) 
        @p =[]
        @has_project_types.each do |s| @p.push(s.project_type_id) end
        @project_types = ProjectType.where(id: @p)

        #@project_types = ProjectType.all
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

