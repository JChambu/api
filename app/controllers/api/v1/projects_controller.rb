module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :validate_api_key!
      before_action :set_project, only: [:show, :update, :destroy]

      # GET /projects
      # GET /projects.json
      def index
        @projects = Project.where(project_type_id: params[:project_type_id])
        render json: @projects
      end

      # GET /projects/1
      # GET /projects/1.json
      def show
      end

      # POST /projects
      # POST /projects.json
      def create
        
        @project = Project.new()
        @project['properties'] = params[:properties]
        @project['project_type_id'] = params[:project_type_id]

        if @project.save
          render json:   :create_correctamente
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /projects/1
      # PATCH/PUT /projects/1.json
      def update
        if @project.update(project_params)
          render :show, status: :ok, location: @project
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end

      # DELETE /projects/1
      # DELETE /projects/1.json
      def destroy
        @project.destroy
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_project
        @project = Project.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def project_params
        params.require(:project).permit(:properties, :project_type_id)
      end
    end
  end
end
