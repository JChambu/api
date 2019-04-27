class ProjectFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :field_type_id, :project_type_id, :key, :required, :items, :regexp, :elements, :hidden

  def items
    @m = []
    if !object.choice_list_id.nil?
      @c = ChoiceList.find(object.choice_list_id)
      @d = ChoiceListItem.where(choice_list_id: @c.id)

      @d.each do |i|
        @m << {"id": i.id, "name":i.name}
      end
    end
    @m
  end
  
  def elements

    if object.field_type_id == 7
      @elements = []
      @items= []

      @arr = ProjectSubfield.where(project_field_id: object.id)
      @arr.each do |e|
                @choice_list_subitem = ''
                if !e.choice_list_id.nil?
                  @choice_list_subitem = Project.show_choice_list(e.choice_list_id)
                end

        @elements << {id: e.id, "name": e.name, field_type_id: e.field_type_id, project_field_id: object.id, "required": e.required, "regexp": regexp_name(e.regexp_type_id), "items":@choice_list_subitem }
      end

    end
       @elements
  end


  def regexp_name regexp_type

    @regexp_name =''
    if !regexp_type.nil?
      r = RegexpType.find(object.regexp_type_id)
      @regexp_name = r.expresion
    end
    @regexp_name
  end



  def regexp
    @regexp =''
    if !object.regexp_type_id.nil?
      @r = RegexpType.find(object.regexp_type_id)
      @regexp = @r.expresion
    end
    @regexp
  end
end
