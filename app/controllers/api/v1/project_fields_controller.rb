module Api 
  module V1

class ProjectFieldsController < ApplicationController
  before_action :validate_api_key!
  before_action :set_project_field, only: [:show, :update, :destroy]

  # GET /api/v1/projec_fields
  # GET /api/v1/projec_fields.json
  def index
    @project_fields = ProjectField.where(project_type_id: params[:project_type_id]).where(hidden: false).order(:id)
        render json: @project_fields
  end

  # GET /api/v1/projec_fields/1
  # GET /api/v1/projec_fields/1.json
  def show
  
        render json: @project_field
  end

  # POST /api/v1/projec_fields
  # POST /api/v1/projec_fields.json
  def create
    @api_v1_project_field = ProjectField.new(project_field_params)

    if @api_v1_project_field.save
      render :show, status: :created, location: @api_v1_project_field
    else
      render json: @api_v1_project_field.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projec_fields/1
  # PATCH/PUT /api/v1/projec_fields/1.json
  def update
    if @api_v1_project_field.update(project_field_params)
      render :show, status: :ok, location: @api_v1_project_field
    else
      render json: @api_v1_project_field.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projec_fields/1
  # DELETE /api/v1/projec_fields/1.json
  def destroy
    @api_v1_project_field.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_field
      @project_field = ProjectField.where(project_type_id: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_field_params
      params.require(:project_field).permit(:name, :field_type, :project_type_id, :key)
    end
end
  end
  end
