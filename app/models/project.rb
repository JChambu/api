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

  def self.show_data_new project_type_id, date_last_row, time_last_row, page
    updated_date = [date_last_row, time_last_row].join(" ").to_datetime
    type_geometry = ProjectType.where(id: project_type_id).pluck(:type_geometry)
    if (type_geometry[0] == 'Polygon')
      value = Project.where(project_type_id: project_type_id).where('updated_at >= ?', updated_date).select("st_asgeojson(the_geom) as geom, id, properties, updated_at, project_status_id, user_id ").order(:updated_at,  :id).page(page).per_page(50)
    else
      value = Project.where(project_type_id: project_type_id).where('updated_at >= ?', updated_date).select("st_x(the_geom) as lng, st_y(the_geom) as lat, id, properties, updated_at, project_status_id, user_id ").order(:updated_at, :id).page(page).per_page(50)
    end
    data = []
    value.each do |row|
      form={}
      row.properties.each do |k, v| 
        field = ProjectField.where(key: "#{k}").where(project_type_id: project_type_id).select(:id).first
        if !field.nil? 
          form.merge!("#{field.id}": v)
        end 
      end
    if (type_geometry[0] == 'Polygon')
      data.push("id":row.id, "the_geom":[row.geom], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id)
    else  
      data.push("id":row.id, "the_geom":[row.lng, row.lat], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id)
    end
    end
    @data = data
  end

  def self.show_data data

    project = []
    data.properties.each do |item|

      @pf = ProjectField.where(project_type_id: data.project_type_id).where(name: item[0]).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id, :hidden, :sort, :read_only, :popup, :calculated )
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
      if (type_geometry[0] == 'Polygon')
        data.push("id":row.id, "the_geom":[row.geom], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id, "user_id": row.user_id)
      else  
        data.push("id":row.id, "the_geom":[row.lng, row.lat], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id, "user_id": row.user_id)
      end
    end
    @data = data
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
        @project_type = ProjectType.find(data['project_type_id'])

        data['values'].each do |v,k|
          field = ProjectField.where(id: v.to_i).select(:key).first
          value_name.merge!("#{field.key}": k )
        end
        @project['properties'] = value_name
        @project['project_type_id'] = data['project_type_id']
        @project['user_id'] = data['user_id']
        type_geometry =  @project_type.type_geometry 
        if type_geometry == 'Polygon'
          @coord = data['the_geom'].as_json
          @feature = RGeo::GeoJSON.decode(@coord, :json_parser => :json)
          @project['the_geom'] = @feature.geometry.as_text  if !data['the_geom'].nil? 
        else
          @project['the_geom'] = "POINT(#{data['longitude']} #{data['latitude']})" if !data['longitude'].nil? && !data['longitude'].nil?
        end
        @project['project_status_id'] = data['status_id']

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
      @project = Project.where(project_type_id: data[:project_type_id] ).where(id: data[:project_id]).first
      if !@project.nil?
        if @project.updated_at < data[:lastUpdate]
          value_name = {}
          data['values'].each do |v,k|
            field = ProjectField.where(id: v.to_i).select(:key).first
            if !field.nil?
              value_name.merge!("#{field.key}": k )
            end
          end
          update_row = {properties: value_name, updated_at: data[:lastUpdate], user_id: data[:user_id]}
          if @project.status_update_at < data[:status_update_at] 
            update_row.merge!(status_update_at: data[:status_update_at], project_status_id: data[:status_id] )
          end
          if @project.update_attributes(update_row)
            localID = data[:localID]
            result_hash.merge!({"#{@project.id}": "ok"}) 
          end
          return [result_hash]
        end
      end
    end
  end
  
  def self.save_rows_project_data_childs project_data_child
    result_hash = {}

    if !project_data_child['projects']['childs'].nil?
      project_data_child['projects']['childs'].each do |data|
        child_data = ProjectDataChild.new()
        child_data[:project_id] = data['IdFather']

        value_name = {}
        data['values'].each do |v|
          v[0].each do |a,b|

            field = ProjectSubfield.where(id: a.to_i).select(:key).first
            if !field.nil?
              value_name.merge!("#{field.key}": b ) 
            end
          end
        end
        child_data[:properties] = data['values']
        child_data[:project_field_id] = data['field_id']
        child_data[:user_id] = data[:user_id]
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
