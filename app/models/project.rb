class Project < ApplicationRecord
   require 'rgeo/shapefile'
   require 'rgeo/geo_json'

  belongs_to :project_type
  has_many :photos
  accepts_nested_attributes_for :photos
end
