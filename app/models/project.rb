class Project < ApplicationRecord
  require 'rgeo/shapefile'
  require 'rgeo/geo_json'

  has_paper_trail
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

  def self.row_active row_active
    if row_active == 'true'
      where('projects.row_active = ? ', true)
    else
      where('projects.row_active IS Not NULL ')
    end
  end

  def self.current_season current_season
    if current_season == 'true'
      where('projects.current_season = ? ', true)
    else
      where('projects.current_season IS Not NULL ')
    end
  end

  def self.row_quantity project_type_id, updated_sequence, row_active, current_season, current_user

    @rows = Project.row_active(row_active).current_season(current_season).where(project_type_id: project_type_id).where('update_sequence > ?', updated_sequence).where.not(user_id: '74')
    @owner = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).pluck(:owner).first
    @rows = @rows.where(user_id: current_user) if !@owner.nil? && @owner != false
    # Aplica filtro por atributo
    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first
    @project_filters.properties.to_a.each do |prop|
      @rows = @rows.where(" projects.properties->>'" + prop[0] + "' = '#{prop[1]}'")
    end
    @rows = @rows.count
    @rows
  end

  # Consulta los datos de los registros padres
  def self.show_data_new project_type_id, updated_sequence, page, row_active, current_season, current_user
    type_geometry = ProjectType.where(id: project_type_id).pluck(:type_geometry)
    value = ''

    # Realiza la consulta a la db
    if (type_geometry[0] == 'Polygon')
      value = Project.row_active(row_active).current_season(current_season).where(project_type_id: project_type_id).where('update_sequence > ?', updated_sequence).where.not(user_id: '74').select("shared_extensions.st_asgeojson(the_geom) as geom, id, properties, updated_at, project_status_id, user_id, the_geom, update_sequence, row_active, current_season")
    else
      value = Project.row_active(row_active).current_season(current_season).where(project_type_id: project_type_id).where('update_sequence > ?', updated_sequence).where.not(user_id: '74').select("shared_extensions.st_x(the_geom) as lng, shared_extensions.st_y(the_geom) as lat, id, properties, updated_at, project_status_id, user_id, the_geom, update_sequence, row_active, current_season")
    end

    @owner = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).pluck(:owner).first
    value = value.where(user_id: current_user) if !@owner.nil? && @owner != false
    # Aplica filtro por atributo
    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first
    @project_filters.properties.to_a.each do |prop|
      value = value.where(" projects.properties->>'" + prop[0] + "' = '#{prop[1]}'")
    end

    value = value.order(:update_sequence).page(page).per_page(50)
    data = []
    geom_text = ''

    value.each do |row|

      # Arma el form con los datos del prototipo
      form={}
      row.properties.each do |k, v|
        field = ProjectField.where(key: "#{k}").where(project_type_id: project_type_id).select(:id).first
        if !field.nil?
          form.merge!("#{field.id}": v)
        end
      end

      geom_text = row.the_geom.as_text if !row.the_geom.nil?

      # Arma la colección con los datos a devolver
      if (type_geometry[0] == 'Polygon')
        data.push("id":row.id, "the_geom":[row.geom], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id, "user_id": row.user_id, "geometry": geom_text, "update_sequence": row.update_sequence, "row_active": row.row_active, "current_season": row.current_season)
      else
        data.push("id":row.id, "the_geom":[row.lng, row.lat], "form_values":form, "updated_at":row.updated_at, "status_id": row.project_status_id, "user_id": row.user_id, "geometry": geom_text, "update_sequence": row.update_sequence, "row_active": row.row_active, "current_season": row.current_season)
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

          if !field.nil?
            if field.key != 'app_estado' && field.key != 'app_usuario' && field.key != 'app_id'
              value_name.merge!("#{field.key}": k )
            end
          end

          value_name.merge!('app_usuario': data[:user_id])
          value_name.merge!('app_estado': data[:status_id])
          @project['properties'] = value_name
          @project['project_type_id'] = data['project_type_id']
          @project['user_id'] = data['user_id']
          type_geometry =  @project_type.type_geometry
          @project['the_geom'] = data['geometry'] if !data['geometry'].nil?
          @project['project_status_id'] = data['status_id']
          @project['row_active'] = data['row_active']
        end
        if @project.save
          @project['properties'].merge!('app_id':@project.id)
          @project.save!
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
              if field.key != 'app_estado' && field.key != 'app_usuario' && field.key != 'app_id'
                value_name.merge!("#{field.key}": k )
              end
              value_name.merge!('app_usuario': data[:user_id])
              value_name.merge!('app_estado': data[:status_id])
              value_name.merge!('app_id': @project.id)
            end
          end
          update_row = {properties: value_name, updated_at: data[:lastUpdate], user_id: data[:user_id], the_geom: data[:geometry], project_status_id: data[:status_id], row_active: data[:row_active] }

          if data[:row_active] == 'false'
            update_row_child_inactive(data[:project_id])
          end

          if @project.update_attributes(update_row)
            localID = data[:localID]
            result_hash.merge!({"#{@project.id}": "ok"})
          end
        end
      end
    end
    return [result_hash]
  end

  def self.update_row_child_inactive project_id

      @project_data_child = ProjectDataChild.where(project_id: project_id)
      @project_data_child.update_all(row_active: false)

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
