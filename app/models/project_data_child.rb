class ProjectDataChild < ApplicationRecord
  belongs_to :project



  def self.row_active row_active
    if row_active == 'true'
      where('project_data_children.row_active = ?', true)
    else
      where('project_data_children.row_active IS Not NULL ')
    end
  end



  def self.current_season current_season
    if current_season == 'true'
      where('project_data_children.current_season = ?', true)
    else
      where('project_data_children.current_season IS Not NULL ')
    end
  end



  def self.show_data_new project_type_id, updated_sequence, page, row_active, current_season, current_user
    value = Project.
      joins(:project_data_child).
      where(project_type_id: project_type_id).
      where('project_data_children.update_sequence > ?', updated_sequence).
      row_active(row_active).
      current_season(current_season).
      where.not('project_data_children.user_id = 74' ).
      select("project_data_children.id, project_data_children.properties, project_data_children.updated_at,  project_data_children.user_id, project_data_children.project_id as project_data_id, project_data_children.project_field_id as project_field_id, project_data_children.update_sequence, project_data_children.row_active, project_data_children.current_season ")

    @owner = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).pluck(:owner).first
    value = value.where(user_id: current_user) if !@owner.nil? && @owner != false

    # Aplica filtro por atributo
    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first
    @project_filters.properties.to_a.each do |prop|
      value = value.where(" projects.properties->>'" + prop[0] + "' = '#{prop[1]}'")
    end
    value = value.order('project_data_children.update_sequence').page(page).per_page(50)
    data = []
    geom_text = ''
    value.each do |row|
      form={}
      row.properties.each do |k, v|
        form.merge!("#{k}": v)
      end
      data.push("id":row.id, "project_data_id": row.project_data_id, "project_field_id": row.project_field_id,  "form_values":form, "updated_at":row.updated_at,  "user_id": row.user_id, "update_sequence": row.update_sequence, "row_active": row.row_active, "current_season": row.current_season )
      @data = data
    end
  end



  def self.row_quantity_children project_type_id, updated_sequence, row_active, current_season, current_user
    @rows = ProjectDataChild.joins(:project).row_active(row_active).current_season(current_season).where("projects.project_type_id = ?", project_type_id).where('project_data_children.update_sequence > ?', updated_sequence).where.not('project_data_children.user_id = 74').select("project_data_children.update_sequence")
    @owner = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).pluck(:owner).first
    @rows = @rows.where(user_id: current_user) if !@owner.nil? && @owner != false
    @rows = @rows.count
    @rows
  end
end
