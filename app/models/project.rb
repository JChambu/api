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


  # Recupera la cantidad de registros padres a sincronizar
  def self.row_quantity project_type_id, updated_sequence, row_active, current_season, current_user
    @rows = Project
      .row_active(row_active)
      .current_season(current_season)
      .where(project_type_id: project_type_id)
      .where('update_sequence > ?', updated_sequence)
      .where.not(user_id: '74')
    # Aplica filtro owner
    @owner = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).pluck(:owner).first
    @rows = @rows.where(user_id: current_user) if !@owner.nil? && @owner != false
    # Aplica filtro por atributo
    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first
    if !@project_filters.nil? && @project_filters != false
      @project_filters.properties.to_a.each do |prop|
        @rows = @rows.where(" projects.properties->>'" + prop[0] + "' = '#{prop[1]}'")
      end
    end
    @rows = @rows.count
    @rows
  end


  # Recupera los registros padres a sincronizar
  def self.show_data_new project_type_id, updated_sequence, page, row_active, current_season, current_user
    type_geometry = ProjectType.where(id: project_type_id).pluck(:type_geometry)
    value = ''

    # Recupera los registros dependiendo de su geometría
    if (type_geometry[0] == 'Polygon')
      value = Project
        .row_active(row_active)
        .current_season(current_season)
        .where(project_type_id: project_type_id)
        .where('update_sequence > ?', updated_sequence)
        .where.not(user_id: '74')
        .select("
          shared_extensions.st_asgeojson(the_geom) as geom,
          id,
          properties,
          gwm_created_at,
          gwm_updated_at,
          project_status_id,
          user_id,
          the_geom,
          update_sequence,
          row_active,
          current_season
        ")
    else
      value = Project
        .row_active(row_active)
        .current_season(current_season)
        .where(project_type_id: project_type_id)
        .where('update_sequence > ?', updated_sequence)
        .where.not(user_id: '74')
        .select("
          shared_extensions.st_x(the_geom) as lng,
          shared_extensions.st_y(the_geom) as lat,
          id,
          properties,
          gwm_created_at,
          gwm_updated_at,
          project_status_id,
          user_id,
          the_geom,
          update_sequence,
          row_active,
          current_season
        ")
    end

    # Aplica filtro owner
    @owner = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).pluck(:owner).first
    value = value.where(user_id: current_user) if !@owner.nil? && @owner != false

    # Aplica filtro por atributo
    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first
    if !@project_filters.nil? && @project_filters != false
      @project_filters.properties.to_a.each do |prop|
        value = value.where(" projects.properties->>'" + prop[0] + "' = '#{prop[1]}'")
      end
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
        data.push(
          "id":row.id,
          "the_geom":[row.geom],
          "form_values":form,
          "gwm_created_at":row.gwm_created_at,
          "gwm_updated_at":row.gwm_updated_at,
          "status_id": row.project_status_id,
          "user_id": row.user_id,
          "geometry": geom_text,
          "update_sequence": row.update_sequence,
          "row_active": row.row_active,
          "current_season": row.current_season
        )
      else
        data.push(
          "id":row.id,
          "the_geom":[row.lng, row.lat],
          "form_values":form,
          "gwm_created_at":row.gwm_created_at,
          "gwm_updated_at":row.gwm_updated_at,
          "status_id": row.project_status_id,
          "user_id": row.user_id,
          "geometry": geom_text,
          "update_sequence": row.update_sequence,
          "row_active": row.row_active,
          "current_season": row.current_season
        )
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


  def self.default_filter_by_timer timer

    case timer
    when 'Semana'
      where("extract(week from small_geom.gwm_created_at) != ?", Date.today.cweek)
    when 'Mes'
      where("extract(month from small_geom.gwm_created_at) != ?", Date.today.month)
    when 'Año'
      where("extract(year from small_geom.gwm_created_at) != ?", Date.today.year)
    when 'No'
      where.not("small_geom.id": nil) # Omite el where con una clause que siempre se va a cumplir
    end

  end


  # Resetea los estados a su valor por default (se ejecuta con arask)
  def self.reset_inheritable_statuses

    # Busca los estados heredables ordenados por level y prioridad
    statuses = ProjectStatus
      .joins("INNER JOIN project_types ON project_types.id = project_statuses.project_type_id")
      .where(status_type: "Heredable")
      .order("project_types.level ASC")
      .order(priority: :desc)

    # Cicla los estados heredados
    statuses.each do |status|

      # Busca los big_geom que contengan small_geom del periodo anterior
      projects_to_default = Project
        .select("big_geom.id")
        .from("projects AS big_geom, projects AS small_geom")
        .where("shared_extensions.ST_Contains(big_geom.the_geom, small_geom.the_geom)")
        .where("big_geom.project_type_id = ?", status.project_type_id)
        .where("small_geom.project_type_id = ?", status.inherit_project_type_id)
        .where("big_geom.project_status_id = ?", status.id)
        .where("small_geom.row_active = true")
        .where("small_geom.current_season = true")
        .where("big_geom.row_active = true")
        .where("big_geom.current_season = true")
        .default_filter_by_timer(status.timer)

      # Extrae los ids
      projects_to_default = projects_to_default.uniq.pluck(:id)

      # Busca los big_geom que contengan small_geom del periodo actual
      projects_not_to_default = Project
        .select("big_geom.id")
        .from("projects AS big_geom, projects AS small_geom")
        .where("shared_extensions.ST_Contains(big_geom.the_geom, small_geom.the_geom)")
        .where("big_geom.project_type_id = ?", status.project_type_id)
        .where("small_geom.project_type_id = ?", status.inherit_project_type_id)
        .where("big_geom.project_status_id = ?", status.id)
        .where("small_geom.row_active = true")
        .where("small_geom.current_season = true")
        .where("big_geom.row_active = true")
        .where("big_geom.current_season = true")
        .filter_by_timer(status.timer)

      # Extrae los ids
      projects_not_to_default = projects_not_to_default.uniq.pluck(:id)

      projects_final = Project
        .where(id: projects_to_default)
        .where.not(id: projects_not_to_default)

      # Busca el id del estado predeterminado de este proyecto
      default_status_id = ProjectStatus
        .where(project_type_id: status.project_type_id)
        .where(status_type: 'Predeterminado')
        .pluck(:id)
        .first

      projects_final.each do |p|
        p.project_status_id = default_status_id
        p.save
      end

    end # statuses.each

  end # reset_inheritable_statuses


  def self.filter_by_timer timer

    case timer
    when 'Semana'
      where("extract(week from small_geom.gwm_created_at) = ?", Date.today.cweek)
    when 'Mes'
      where("extract(month from small_geom.gwm_created_at) = ?", Date.today.month)
    when 'Año'
      where("extract(year from small_geom.gwm_created_at) = ?", Date.today.year)
    when 'No'
      where.not("small_geom.id": nil) # Omite el where con una clause que siempre se va a cumplir
    end

  end



  def self.update_inheritable_statuses

    # Busca todas las corporaciones
    tentants = Customer.all.pluck(:subdomain)

    tentants.each do |tenant|

      Apartment::Tenant.switch(tenant) do

        # Busca los estados heredables ordenados por level y prioridad
        statuses = ProjectStatus
          .joins("INNER JOIN project_types ON project_types.id = project_statuses.project_type_id")
          .where(status_type: "Heredable")
          .order("project_types.level ASC")
          .order(priority: :desc)

        @projects_to_update_hash = {}

        # Cicla los estados heredados
        statuses.each do |status|

          # Busca los registros de big_geom a los que se les debe modificarles el estado
          projects_to_update = Project
            .select("big_geom.*")
            .from("projects AS big_geom, projects AS small_geom")
            .where("shared_extensions.ST_Contains(big_geom.the_geom, small_geom.the_geom)")
            .where("big_geom.project_type_id = ?", status.project_type_id)
            .where("small_geom.project_type_id = ?", status.inherit_project_type_id)
            .where("small_geom.project_status_id = ?", status.inherit_status_id)
            .where("small_geom.row_active = true")
            .where("small_geom.current_season = true")
            .where("big_geom.row_active = true")
            .where("big_geom.current_season = true")
            .filter_by_timer(status.timer)
            .uniq

          if !projects_to_update.empty?
            projects_to_update.each do |p|
              @projects_to_update_hash[p.id] = status.id
            end
          end

        end # cierra each status

        @projects_to_update_hash.each do |project_id, status_id|

          project = Project.find_by(id: project_id)

          if project.project_status_id != status_id
            project.project_status_id = status_id
            project.save
          end

        end

      end # Cierra Tenant.switch

    end # Cierra tentants.each

  end # cierra update_inheritable_statuses


  # Guarda los registros padres nuevos
  def self.save_rows_project_data project_data

    result_hash = {}

    if !project_data[:projects].nil?
      project_data[:projects].each do |data|

        @project = Project.new()
        value_name = {}
        @project_type = ProjectType.find(data['project_type_id'])

        # Cicla los registros
        data['values'].each do |v,k|

          # Busca el key de cada registro según su id y guarda key y valor en un hash
          field = ProjectField.where(id: v.to_i).select(:key).first
          if !field.nil?
            if field.key != 'app_estado' && field.key != 'app_usuario' && field.key != 'app_id' && field.key != 'gwm_created_at' && field.key != 'gwm_updated_at'
              value_name.merge!("#{field.key}": k )
            end
          end

          # Actualiza los valores dentro del json
          value_name.merge!('app_usuario': data[:user_id])
          value_name.merge!('app_estado': data[:status_id])
          value_name.merge!('gwm_created_at': data['gwm_created_at'].to_date)
          value_name.merge!('gwm_updated_at': data['gwm_updated_at'].to_date)

          # Carga los valores
          @project['properties'] = value_name
          @project['project_type_id'] = data['project_type_id']
          @project['user_id'] = data['user_id']
          type_geometry = @project_type.type_geometry
          @project['the_geom'] = data['geometry'] if !data['geometry'].nil?
          @project['project_status_id'] = data['status_id']
          @project['row_active'] = data['row_active']
          @project['gwm_created_at'] = data['gwm_created_at']
          @project['gwm_updated_at'] = data['gwm_updated_at']
        end


        if @project.save
          @project['properties'].merge!('app_id': @project.id)
          @project.save!
          localID = data[:localID]
          result_hash.merge!({"#{localID}":@project.id})
        end
      end
      update_inheritable_statuses
      return [result_hash]
    end
    return
  end


  # Actualiza los registros padres existentes
  def self.update_rows_project_data project_data

    result_hash = {}
    project_data[:projects].each do |data|
      @project = Project.where(project_type_id: data[:project_type_id]).where(id: data[:project_id]).first

      if !@project.nil?

        # Si la fecha del registro es más nueva que la almacenada, lo actualiza
        if @project.gwm_updated_at < data[:gwm_updated_at]
          value_name = {}
          data['values'].each do |v,k|
            field = ProjectField.where(id: v.to_i).select(:key).first
            if !field.nil?
              if field.key != 'app_estado' && field.key != 'app_usuario' && field.key != 'app_id' && field.key != 'gwm_updated_at'
                value_name.merge!("#{field.key}": k )
              end
              value_name.merge!('app_usuario': data[:user_id])
              value_name.merge!('app_estado': data[:status_id])
              value_name.merge!('app_id': @project.id)
              value_name.merge!('gwm_updated_at': data[:gwm_updated_at].to_date)
            end
          end
          update_row = {
            properties: value_name,
            gwm_updated_at: data[:gwm_updated_at],
            user_id: data[:user_id],
            the_geom: data[:geometry],
            project_status_id: data[:status_id],
            row_active: data[:row_active]
          }

          # Si se desactiva un registro padre, desactiva los hijos
          if data[:row_active] == 'false'
            update_row_child_inactive(data[:project_id], data[:gwm_updated_at])
          end

          if @project.update_attributes(update_row)
            localID = data[:localID]
            result_hash.merge!({"#{@project.id}": "ok"})
          end
        end
      end
    end
    update_inheritable_statuses
    return [result_hash]
  end


  # Desactiva los registros hijos cuando se ha desactivado el padre
  def self.update_row_child_inactive project_id, gwm_updated_at

    @project_data_child = ProjectDataChild.where(project_id: project_id)
    @project_data_child.update_all(row_active: false, gwm_updated_at: gwm_updated_at)
  end


  # Guarda los registros padres nuevos y las fotos de padres e hijos
  def self.save_rows_project_data_childs project_data_child

    result_hash = {}

    if !project_data_child['projects']['childs'].nil?

      # Cicla todos los hijos
      project_data_child['projects']['childs'].each do |data|

        # Guarda los registros hijos
        child_data = ProjectDataChild.new()
        child_data[:project_id] = data['IdFather']
        child_data[:properties] = data['values']
        child_data[:project_field_id] = data['field_id']
        child_data[:user_id] = data[:user_id] # FIXME: Este campo a veces se carga con 0
        child_data[:gwm_created_at] = data[:gwm_created_at]

        if child_data.save
          localID = data[:localID]
          result_hash.merge!({"#{localID}":child_data.id})
        end

        # Guarda las fotos de los hijos
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
      return [result_hash]
    end

    # Guarda las fotos de los padres
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
