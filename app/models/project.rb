class Project < ApplicationRecord
  require 'rgeo/shapefile'
  require 'rgeo/geo_json'

  belongs_to :project_type
  has_many :photos
  accepts_nested_attributes_for :photos


  def self.show_data_new project_type_id

    value = Project.where(project_type_id: project_type_id).limit(2).select("st_x(the_geom) as lng, st_y(the_geom) as lat, id, properties").limit(2)
    data = []
    value.each do |row|
      form=[]
      row.properties.each do |k, v| 
        field = ProjectField.where(key: "#{k}").where(project_type_id: project_type_id).select(:id).first
        form.push("#{field.id}": v)
      end
      data.push("id":row.id, "the_geom":[row.lng, row.lat], "form_values":form)
    end
    @data = data
  end





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

        @repetible = ProjectSubfield.where(project_field_id: row.id).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id )
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
                      @subvalue.push(sub_row.as_json.merge("name":sub_row.name, "items":  @choice_list_subitem, "regexp": @regexp_subitem, "field_type_id": sub_row.field_type_id, "required": sub_row.required))
                    end
        end
      end
      @pf = { "id":row.id, "name": row.name, "field_type_id":row.field_type_id, "items": @choice_list_item, "required": row.required, "regexp": @regexp, "hidden": @hidden, "sort": @sort, "elements":@subvalue}
      project.push @pf
      @pp = project
    end
    project
  end




  def self.show_data data

    project = []
    data.properties.each do |item|

      @pf = ProjectField.where(project_type_id: data.project_type_id).where(name: item[0]).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id, :hidden, :sort )
      if !@pf.empty?
        @choice_list_item = ''
        if !@pf[0].choice_list_id.nil?
          @choice_list_item = show_choice_list(@pf[0].choice_list_id)
        end
        @regexp =''
        if !@pf[0].regexp_type_id.nil?
          @regexp = show_regexp_type(@pf[0].regexp_type_id)
        end

        @hidden = @pf[0].hidden
        @sort = @pf[0].sort
        @value = item[1]
        if @pf[0].field_type_id == 7
          if !@value.empty?

            @ss = @value.instance_of? String
            if @ss
              @ss = JSON.parse(@value)
            else
              @ss = @value
            end
            @subvalue = []
            @ss.each do |subitem|
              @su = subitem
              @aa = []
              subitem.each do |row|
                @r = row

                #  row.each do |element|
                # @e = element
                @repetible = ProjectSubfield.where(project_field_id: @pf[0].id).where(name: row[0]).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id )
                if !@repetible.empty?
                  @choice_list_subitem = '' 
                  if !@repetible[0].choice_list_id.nil?
                    @choice_list_subitem = show_choice_list(@repetible[0].choice_list_id)
                  end
                  @regexp =''
                  if !@repetible[0].regexp_type_id.nil?
                    @regexp_subitem = show_regexp_type(@repetible[0].regexp_type_id)
                  end
                  if !@repetible.empty?
                    @repetible = @repetible[0].as_json.merge("items":  @choice_list_subitem, "regexp": @regexp_subitem, "value":row[1])
                    @aa.push(@repetible)
                  end

                end

              end
              @subvalue += [@aa]
            end
            @value = @subvalue
          end
        end
        @pf +=[items: @choice_list_item]
        @pf +=[regexp: @regexp]
        @pf += [value: @value]
        @pf +=[hidden: @hidden]
        @pf +=[sort: @sort]

        project.push @pf
        @pp = project
      end
    end
    project
  end



  def self.show_choice_list id 
    items=[]
    choice_list = ChoiceList.find(id)
    choice_list_item  = ChoiceListItem.where(choice_list_id: choice_list.id)
    choice_list_item.each do |i|
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
