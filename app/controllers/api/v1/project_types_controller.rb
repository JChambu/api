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
          show_field = ProjectField.show_schema_new(project_type)
          project_statuses = ProjectField.status_types(s.project_type_id).as_json
          data = {
            "id":project_type.id,
            "name":project_type.name,
            "enabled_as_layer": project_type.enabled_as_layer,
            "add_rows":project_type.add_rows,
            "form": show_field,
            "tracking": project_type.tracking,
            "project_statuses": project_statuses,
            "type_geometry": project_type.type_geometry,
            "geo_restriction": project_type.geo_restriction,
            "cover": project_type.cover,
            "multiple_edition": project_type.multiple_edition,
            "level": project_type.level,
          }

          @p.push(data)
        end
        @result = {"data":@p}
        render json: @result
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
