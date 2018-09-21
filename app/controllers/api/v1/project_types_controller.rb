module Api
  module V1
    class ProjectTypesController < ApplicationController 
      def index
        @project_types = ProjectType.order('created_at Desc')
         render json: @project_types
      end
    end
  end
end

