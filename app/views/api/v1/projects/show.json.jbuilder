json.array! @project.properties do |item|
  json.value item[1]
  json.project_type @project.project_type_id
  @project_field = ProjectField.where(project_type_id: @project.project_type_id).where(name: item[0]).select(:id, :name, :field_type_id)
  json.project_field @project_field
  
end

