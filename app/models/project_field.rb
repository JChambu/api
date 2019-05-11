class ProjectField < ApplicationRecord

  belongs_to :project_type
  belongs_to :regexp_type


  def self.show_schema_new data

    project = []
    project_field = ProjectField.where(project_type_id: data.id).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id, :hidden, :sort ).order(:sort)
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
      @sort = row.sort
  
        @subvalue = []          
      if row.field_type_id == 7
        #       #  row.each do |element|
        #          # @e = element

        @repetible = ProjectSubfield.where(project_field_id: row.id).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id, :hidden )
        @repetible.each do |sub_row|
                   @choice_list_subitem = '' 
                   if !sub_row.choice_list_id.nil?
                     @choice_list_subitem = show_choice_list(sub_row.choice_list_id)
                   end
                   @regexp =''
                   if !sub_row.regexp_type_id.nil?
                     @regexp_subitem = show_regexp_type(sub_row.regexp_type_id)
                   end
                    if !@repetible.empty?
                      @subvalue.push(sub_row.as_json.merge("name":sub_row.name, "items":  @choice_list_subitem, "regexp": @regexp_subitem, "field_type_id": sub_row.field_type_id, "required": sub_row.required, "hidden":sub_row.hidden))
                    end
        end
      end
      @pf = { "id":row.id, "name": row.name, "field_type_id":row.field_type_id, "items": @choice_list_item, "required": row.required, "regexp": @regexp, "hidden": @hidden, "sort": @sort, "elements":@subvalue}
      project.push @pf
      @pp = project
    end
    project
  end


end
