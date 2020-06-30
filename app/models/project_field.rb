class ProjectField < ApplicationRecord

  belongs_to :project_type
  belongs_to :regexp_type


  def self.show_schema_new data

    project = []
    project_field = ProjectField.where(project_type_id: data.id).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id, :hidden, :read_only, :sort, :popup, :calculated_field, :role, :data_script, :filter_field ).order(:sort)
    project_field.each do |row|

      @rr = row
      @choice_list_item = ''

      if !row.choice_list_id.nil?
        @choice_list_item = show_choice_list(row.choice_list_id)
      end
      @regexp =''
      if !row.regexp_type_id.nil?
        @regexp = show_regexp_type(row.regexp_type_id)
      end

      @hidden = row.hidden
      @readonly = row.read_only
      @sort = row.sort
      @popup = row.popup
      @calculated = row.calculated_field
      @role = row.role
      @data_script = row.data_script
      @filter_field = row.filter_field
        @subvalue = []
      if row.field_type_id == 7
        @repetible = ProjectSubfield.where(project_field_id: row.id).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id, :hidden, :read_only, :popup, :calculated_field, :role, :data_script ).order(:sort)
        @repetible.each do |sub_row|
                   @choice_list_subitem = ''
                   if !sub_row.choice_list_id.nil?
                     @choice_list_subitem = show_choice_list(sub_row.choice_list_id)
                   end
                   @regexp_subitem =''
                   if !sub_row.regexp_type_id.nil?
                     @regexp_subitem = show_regexp_type(sub_row.regexp_type_id)
                   end
                    if !@repetible.empty?
                      @subvalue.push(sub_row.as_json.merge("name":sub_row.name, "items":  @choice_list_subitem , "regexp": @regexp_subitem, "field_type_id": sub_row.field_type_id, "required": sub_row.required, "hidden":sub_row.hidden, "read_only":sub_row.read_only, "popup":sub_row.popup, "calculated":sub_row.calculated_field, "role":sub_row.role, "data_script": sub_row.data_script))
                    end
        end
      end


      @pf = { "id":row.id, "name": row.name, "field_type_id":row.field_type_id, "items": @choice_list_item, "required": row.required, "regexp": @regexp, "hidden": @hidden, "sort": @sort, "elements":@subvalue, "read_only":@readonly, "popup":@popup, "calculated": @calculated, "role":@role, "data_script": @data_script, filter_field: @filter_field }
      project.push @pf
      @pp = project
    end
    project
  end

  def self.status_types project_type_id
    @project_statuses = ProjectStatus.where(project_type_id: project_type_id).select(:id, :name, :color).order(:name)
  end



  def self.show_choice_list id
    items=[]
    choice_list = ChoiceList.find(id)
    choice_list_item  = ChoiceListItem.where(choice_list_id: choice_list.id)
    sorted_choice_list_items = choice_list_item.sort { |x, y| x[:name] <=> y[:name] }
    sorted_choice_list_items.each do |i|
      items << {"id": i.id, "name":i.name}
    end
    items
  end


  def self.show_regexp_type id
    r = RegexpType.find(id)
    regexp = r.expresion
    regexp
  end
end
