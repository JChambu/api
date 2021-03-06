module Api
  module V1
    class ProjectsController < ApplicationController
      before_action :validate_api_key!
      before_action :set_project, only: [:show, :update, :destroy]


      def check_row_quantity
        project_type_id = params[:project_type_id]
        updated_sequence = params[:updated_sequence].to_i
        row_active = params[:row_active]
        @count = Project.row_quantity( project_type_id, updated_sequence, row_active, current_user.id)
        render json: {'row_quantity': @count}
      end


      def check_row_quantity_children
        project_type_id = params[:project_type_id]
        updated_sequence = params[:updated_sequence].to_i
        row_active = params[:row_active]
        @count = ProjectDataChild.row_quantity_children( project_type_id, updated_sequence, row_active, current_user.id)
        render json: {'row_quantity': @count}
      end


      def list_data
        updated_sequence = params[:updated_sequence].to_i
        project_type_id = params[:project_type_id]
        page = params[:page].to_i
        row_active = params[:row_active]
        @data = Project.show_data_new(project_type_id, updated_sequence, page, row_active, current_user.id)
        render json: {data: @data}
      end


      def list_data_children
        updated_sequence = params[:updated_sequence].to_i
        project_type_id = params[:project_type_id]
        page = params[:page].to_i
        row_active = params[:row_active]
        @data = ProjectDataChild.show_data_new(project_type_id, updated_sequence, page, row_active, current_user.id)
        render json: {data: @data}
      end


      def save_rows
        @a = Project.save_rows_project_data params
        render json: {data: @a}
      end

      def save_row_children
        @c = Project.save_rows_project_data_childs params
        render json: {data: @c}
      end

      def update_rows
        @u = Project.update_rows_project_data params
        render json: {data: @u }
      end


      def synchronization
        @params_date = params[:date].to_datetime
        @rows = Project.where("updated_at > ?",  @params_date)
        @rows = @rows.where(project_type_id: params[:project_type_id])
        @rows = @rows.order(:updated_at)
        @rows = @rows.limit(50)
        render json: {data: @rows}
      end

      def synchronization_update
        status = []

        if !params[:project.nil?]
          params[:project].each do |a|
            @id = a[:id]
            @row = Project.where(id: a[:id])

            if (@row.update(a[:id], properties: a[:properties]))
              status << { "#{@id}": 'ok'}
            else
              status << {"#{@id}": 'bad'}
            end

            if !a['photos'].nil?
              a['photos'].each do |photo|
                @photo = Photo.new
                @photo['name'] = photo['name']
                @photo['image'] = photo['image']
                @photo['project_id'] = @id
                @photo.save
              end
            end
          end

          render json:   {status: status}
        end
      end

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

        @pp = Project.show_data( @project)
        @sort_field = @pp.sort { |a,b|  a[5][:sort] <=> b[5][:sort]}
        @p = []
        @photos_attributes = Photo.where(project_id: @project.id)
        @photos_attributes.each do |photo|
          @p << {"name": photo.name, "image":photo.image, "project_id": photo.project_id}
        end
        render json: {data: @sort_field, photos_attributes: @p}
      end

      # POST /projects
      # POST /projects.json
      def create
        @dat = params[:data]
        @dat.each do |data|
          @d = data
          @project = Project.new()
          @project['properties'] = data['properties']
          @project['project_type_id'] = data['project_type_id']
          @the_geom = data['the_geom']
          @project['the_geom'] = "POINT(#{data['longitude']} #{data['latitude']})" if !data['longitude'].nil? && !data['longitude'].nil?
          @project.save

          if !data['photos_attributes'].nil?

            data['photos_attributes'].each do |photo|

              @photo = Photo.new
              @photo['name'] = photo['name']
              @photo['image'] = photo['image']
              @photo['project_id'] = @project.id
              @photo.save
            end

          end
        end
        render json:   {status: :create_correctamente}
      end

      # PATCH/PUT /projects/1
      # PATCH/PUT /projects/1.json
      def update
        @project['properties'] = params[:project][:properties]
        if !params[:project]['photos'].nil?
          params[:project]['photos'].each do |photo|
            @photo = Photo.new
            @photo['name'] = photo['name']
            @photo['image'] = photo['image']
            @photo['project_id'] = @project.id
            @photo.save
          end
        end

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
        params.require(:project).permit(:properties, :project_type_id, photos_attributes:[:id, :name])
      end
    end
  end
end
