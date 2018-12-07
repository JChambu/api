module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :validate_api_key!
      before_action :set_project, only: [:show, :update, :destroy]

      # GET /projects
      # GET /projects.json
      def index
        @projects = Project.where(project_type_id: params[:project_type_id]).select(:id, :the_geom, :project_type_id).all
        #render json: Oj.dump(@projects.to_json)
        render json: @projects
      end

      # GET /projects/1
      # GET /projects/1.json
      def show
        
       @pp = @project.properties
       project = []
       @pp.each do |item|
       
         @pf = ProjectField.where(project_type_id: @project.project_type_id).where(name: item[0]).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id )
        @m = []
        if !@pf[0].choice_list_id.nil?
          @c = ChoiceList.find(@pf[0].choice_list_id)
          @d = ChoiceListItem.where(choice_list_id: @c.id)
          @d.each do |i|
            @m << {"id": i.id, "name":i.name}
          end
        end
        @regexp =''
        if !@pf[0].regexp_type_id.nil?
          @r = RegexpType.find(@pf[0].regexp_type_id)
          @regexp = @r.expresion
        end
        @pf +=[items: @m]
        @pf +=[regexp: @regexp]
        @pf += [value: item[1]]

        project.push @pf
      end

        render json: {data: project}

      end

      # POST /projects
      # POST /projects.json
      def create
        @dat = params[:data]
         @dat.each do |data|
            @project = Project.new()
            @project['properties'] = data['properties']
            @project['project_type_id'] = data['project_type_id']
            @the_geom = data['the_geom']
            @project['the_geom'] = "POINT(#{data['longitude']} #{data['latitude']})" if !data['longitude'].nil? && !data['longitude'].nil?
            @project.save
        end
          render json:   {status: :create_correctamente}
      end

      # PATCH/PUT /projects/1
      # PATCH/PUT /projects/1.json
      def update
        @project['properties'] = params[:project][:properties]
        if @project.update(project_params)
          render json: {status: :ok}
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
