class ProjectDataChild < ApplicationRecord
  belongs_to :project

  def self.row_active row_active

    if row_active == 'true'
      where(row_active: true)   
    else
      where('row_active IS Not NULL ')
    end
  end
  
  def self.show_data_new project_type_id, updated_sequence, page, row_active
    value = Project.joins(:project_data_child).where(project_type_id: project_type_id).where('project_data_children.update_sequence > ?', updated_sequence).select("project_data_children.id, project_data_children.properties, project_data_children.updated_at,  project_data_children.user_id, project_data_children.project_id as project_data_id, project_data_children.project_field_id as project_field_id, project_data_children.update_sequence ").order('project_data_children.update_sequence, row_active').page(page).per_page(50)
    data = []
    geom_text = ''
    value.each do |row|
      form={}
      row.properties.each do |k, v| 
        form.merge!("#{k}": v)
      end
      data.push("id":row.id, "project_data_id": row.project_data_id, "project_field_id": row.project_field_id,  "form_values":form, "updated_at":row.updated_at,  "user_id": row.user_id, "update_sequence": row.update_sequence, "row_active": row.row_active )
      @data = data
    end
  end

end
