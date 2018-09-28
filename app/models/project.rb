class Project < ApplicationRecord
   require 'rgeo/shapefile'
   require 'rgeo/geo_json'

  belongs_to :project_type
end
