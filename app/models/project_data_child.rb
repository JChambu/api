class ProjectDataChild < ApplicationRecord
  belongs_to :project

  def self.show_data_new project_type_id, date_last_row, time_last_row, page
    updated_date = [date_last_row, time_last_row].join(" ")
    value = Project.joins(:project_data_child).where(project_type_id: project_type_id).where('project_data_children.updated_at >= ?', updated_date).select("project_data_children.id, project_data_children.properties, project_data_children.updated_at,  project_data_children.user_id").order('project_data_children.updated_at',  'project_data_children.id').page(page).per_page(50)
    data = []
    geom_text = ''
    value.each do |row|
      form={}
      row.properties.each do |k, v| 
        form.merge!("#{k}": v)
      end
      data.push("id":row.id,  "form_values":form, "updated_at":row.updated_at,  "user_id": row.user_id )
      @data = data
    end
  end

end
