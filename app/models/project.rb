class Project < ApplicationRecord
  require 'rgeo/shapefile'
  require 'rgeo/geo_json'

  belongs_to :project_type
  has_many :photos
  accepts_nested_attributes_for :photos


  def self.row_quantity project_type_id, date_last_row, time_last_row

    updated_date = [date_last_row, time_last_row].join(" ").to_datetime

    @rows = Project.where(project_type_id: project_type_id).where('updated_at > ?', updated_date).count

  end

  def self.show_data_new project_type_id, date_last_row, time_last_row

    updated_date = [date_last_row, time_last_row].join(" ").to_datetime
    value = Project.where(project_type_id: project_type_id).where('updated_at > ?', updated_date).select("st_x(the_geom) as lng, st_y(the_geom) as lat, id, properties, updated_at ").order(:updated_at).limit(50)
    data = []
    value.each do |row|
      form={}
      row.properties.each do |k, v| 
        field = ProjectField.where(key: "#{k}").where(project_type_id: project_type_id).select(:id).first
        form.merge!("#{field.id}": v)
      end
      data.push("id":row.id, "the_geom":[row.lng, row.lat], "form_values":form, "updated_at":row.updated_at)
    end
    @data = data
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

  def self.save_rows_project_data project_data
    result_hash = {}
    if !project_data[:projects].nil?
    project_data[:projects].each do |data|
      @project = Project.new()

      value_name = {}
      data['values'].each do |v,k|
        field = ProjectField.where(id: v.to_i).select(:key).first
        value_name.merge!("#{field.key}": k )
      end
      @project['properties'] = value_name
      @project['project_type_id'] = data['project_type_id']
      @project['the_geom'] = "POINT(#{data['longitude']} #{data['latitude']})" if !data['longitude'].nil? && !data['longitude'].nil?
      
      if @project.save
        localID = data[:localID]
        result_hash.merge!({"#{localID}":@project.id}) 
      end
      
    end
      return [result_hash]
    end
    return
  end
  
  def self.update_rows_project_data project_data
    result_hash = {}
    project_data[:projects].each do |data|
      @project = Project.where(project_type_id: data[:project_type_id] )

      value_name = {}
      data['values'].each do |v,k|
      field = ProjectField.where(id: v.to_i).select(:key).first
        value_name.merge!("#{field.key}": k )
      end
      @project['properties'] = value_name
      if @project.save
        localID = data[:localID]
        result_hash.merge!({"#{localID}":@project.id}) 
      end
      
    end
return [result_hash]
  end
  
  def self.save_rows_project_data_childs project_data_child
    result_hash = {}

    if !project_data_child['projects']['childs'].nil?
    project_data_child['projects']['childs'].each do |data|
      child_data = ProjectDataChild.new()
      child_data[:project_id] = data['IdFather']

      value_name = {}
      data['values'].each do |v|
        v.each do |a,b|
        field = ProjectSubfield.where(id: a.to_i).select(:key).first
        value_name.merge!("#{field.key}": b )
        end
      end
      child_data[:properties] = data['values']
      child_data[:project_field_id] = data['field_id']
      child_data.save
    end
    end
    if !project_data_child['projects']['photos'].nil?
    project_data_child['projects']['photos'].each do |photo|
        project_photo = Photo.new
        project_photo['name'] = photo['values']['name']
        project_photo['image'] = photo['values']['image']
        project_photo['project_id'] = photo['IdFather']
        project_photo.save
  end
  end
end
end
