class Projects::SynchronizationSerializer < ProjectSerializer
 
   attributes :id, :the_geom, :project_type_id, :properties

  # def the_geom
  #   if !object.the_geom.nil?
  #     [object.the_geom.x,
  #     object.the_geom.y]
  #   end
  # end

  # def properties
  #   object.properties.map do|val, index|
  #     [val, index]
  #   end
 # end
end
