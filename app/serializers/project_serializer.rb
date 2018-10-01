class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :properties, :the_geom, :project_type_id
  def the_geom
    [object.the_geom.x,
     object.the_geom.y]
  end

  def properties
    object.properties.map do|val, index|
      [val, index]


    end
  end
end
