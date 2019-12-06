class Project < ApplicationRecord
  require 'rgeo/shapefile'
  require 'rgeo/geo_json'

  belongs_to :project_type
  has_many :photos
  has_many :project_data_child
  accepts_nested_attributes_for :photos

  before_update :update_sequence_projects

  def update_sequence_projects
    sequence_name = 'projects_update_sequence_seq'
    @a = ActiveRecord::Base.connection.execute("select nextval('#{sequence_name}')")
    self.update_sequence = @a[0]['nextval']
  end


  def self.row_quantity project_type_id, updated_sequence
    @rows = Project.where(project_type_id: project_type_id).where('update_sequence > ?', updated_sequence).count
  end

  def self.row_quantity_children project_type_id, updated_sequence
    @rows = Project.joins(:project_data_child).where(project_type_id: project_type_id).where('project_data_children.update_sequence > ?', updated_sequence).select("project_data_children.update_sequence").count
  end

  def self.show_data_new project_type_id, updated_sequence, page
    type_geometry = ProjectType.where(id: project_type_id).pluck(:type_geometry)
    if (type_geometry[0] == 'Polygon')
      value = Project.where(project_type_id: project_type_id).where('update_sequence >= ?', updated_sequence).select("st_asgeojson(the_geom) as geom, id, properties, updated_at, project_status_id, user_id, the_geom, update_sequence").order(:updated_at,  :id).page(page).per_page(50)
    else
      value = Project.where(project_type_id: project_type_id).where('update_sequence >= ?', updated_sequence).select("st_x(the_geom) as lng, st_y(the_geom) as lat, id, properties, updated_at, project_status_id, user_id, the_geom, update_sequence").order(:updated_at, :id).page(page).per_page(50)
    end
    data = []
    geom_text = ''
    value.each do |row|
      form={}
      row.properties.each do |k, v| 
        field = ProjectField.where(key: "#{k}").where(project_type_id: project_type_id).select(:id).first
        if !field.nil? 
          form.merge!("#{field.id}": v)
        end 
      end
      geom_text = row.the_geom.as_text if !row.the_geom.nil? 
      if (type_geometry[0] == 'Polygon')

        data.push("id":row.id, "the_geom":[row.geom], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id, "user_id": row.user_id, "geometry": geom_text, "update_sequence": row.update_sequence)
      else  
        data.push("id":row.id, "the_geom":[row.lng, row.lat], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id, "user_id": row.user_id, "geometry": geom_text, "update_sequence": row.update_sequence)
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
        @project['the_geom'] = data['geometry'] if !data['geometry'].nil?
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
          update_row = {properties: value_name, updated_at: data[:lastUpdate], user_id: data[:user_id], the_geom: data[:geometry], project_status_id: data[:status_id] }

          # if @project.status_update_at < data[:status_update_at] 
          #   update_row.merge!(status_update_at: data[:status_update_at])
          # end
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
          v.each do |a,b|
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
      
    if !data['photos_child'].nil?
        data['photos_child'].each do |photo_child|
        photo = PhotoChild.new
        photo['name'] = photo_child['values']['name']
        photo['image'] = photo_child['values']['image']
        photo['project_data_child_id'] = child_data.id
        photo.save
      end
    end

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
