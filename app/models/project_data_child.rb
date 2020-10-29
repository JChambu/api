class ProjectDataChild < ApplicationRecord
  belongs_to :project


  # Devuelve where clause para todos los hijos o sólo los row_active = true
  def self.check_row_active row_active
    if row_active == 'true'
      where('project_data_children.row_active = ?', true)
    else
      where('project_data_children.row_active IS NOT NULL')
    end
  end


  # Devuelve where clause para todos los hijos o sólo los current_season = true
  def self.check_current_season current_season
    if current_season == 'true'
      where('project_data_children.current_season = ?', true)
    else
      where('project_data_children.current_season IS NOT NULL')
    end
  end


  # Recupera los registros hijos a sincronizar
  def self.show_data_new project_type_id, updated_sequence, page, row_active, current_season, current_user

    value = ProjectDataChild
      .select('
        project_data_children.id,
        project_data_children.properties,
        project_data_children.gwm_created_at,
        project_data_children.gwm_updated_at,
        project_data_children.user_id,
        project_data_children.project_id AS project_data_id,
        project_data_children.project_field_id,
        project_data_children.update_sequence,
        project_data_children.row_active,
        project_data_children.current_season
      ')
      .joins('INNER JOIN projects main ON main.id = project_data_children.project_id')
      .check_row_active(row_active)
      .check_current_season(current_season)
      .where('main.project_type_id = ?', project_type_id.to_i)
      .where('main.row_active = ?', true)
      .where('main.current_season = ?', true)
      .where('project_data_children.update_sequence > ?', updated_sequence)

    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first


    if !@project_filters.nil?

      # Aplica filtro owner
      if @project_filters.owner == true
        value = value.where(user_id: current_user)
      end

      # Aplica filtro por atributo
      if !@project_filters.properties.nil?
        @project_filters.properties.to_a.each do |prop|
          value = value.where("main.properties->>'" + prop[0] + "' = '#{prop[1]}'")
        end
      end

      # Aplica filtro intercapa
      if !@project_filters.cross_layer_filter_id.nil?

        cross_layer_filter = ProjectFilter.where(user_id: current_user).where(id: @project_filters.cross_layer_filter_id).first

        # Cruza la capa del principal que contiene los hijos con la capa secunadaria
        value = value
          .joins('INNER JOIN projects sec ON shared_extensions.ST_Intersects(main.the_geom, sec.the_geom)')
          .where('sec.project_type_id = ?', cross_layer_filter.project_type_id)
          .where('sec.row_active = ?', true)
          .where('sec.current_season = ?', true)

        # Aplica filtro por owner a capa secundaria
        if cross_layer_filter.owner == true
          value = value.where('sec.user_id = ?', current_user)
        end

        # Aplica filtro por atributo a capa secundaria
        if !cross_layer_filter.properties.nil?
          cross_layer_filter.properties.to_a.each do |prop|
            value = value.where("sec.properties->>'#{prop[0]}' = '#{prop[1]}'")
          end
        end

      end

    end

    value = value.order('project_data_children.update_sequence').page(page).per_page(50)
    data = []
    geom_text = ''
    value.each do |row|
      form = {}
      row.properties.each do |k, v|
        form.merge!("#{k}": v)
      end
      data.push(
        "id": row.id,
        "project_data_id": row.project_data_id,
        "project_field_id": row.project_field_id,
        "form_values": form,
        "gwm_created_at": row.gwm_created_at,
        "gwm_updated_at": row.gwm_updated_at,
        "user_id": row.user_id,
        "update_sequence": row.update_sequence,
        "row_active": row.row_active,
        "current_season": row.current_season
      )
      @data = data
    end
  end


  # Recupera la cantidad de registros hijos a sincronizar
  def self.row_quantity_children project_type_id, updated_sequence, row_active, current_season, current_user

    # NOTE: El parámetro row_active sólo se cruza con los registros hijos,
    # los registros padre se buscan con row_active y current_season true para corregir alguna eliminación incompleta en la db
    # y registros que cruzan los padres también se buscan con row_active y current_season true para no cruzar con no activos

    @rows = ProjectDataChild
      .joins('INNER JOIN projects main ON main.id = project_data_children.project_id')
      .check_row_active(row_active)
      .check_current_season(current_season)
      .where('main.project_type_id = ?', project_type_id.to_i)
      .where('main.row_active = ?', true)
      .where('main.current_season = ?', true)
      .where('project_data_children.update_sequence > ?', updated_sequence)

    @project_filters = ProjectFilter.where(user_id: current_user).where(project_type_id: project_type_id).first

    if !@project_filters.nil?

      # Aplica filtro owner
      if @project_filters.owner == true
        @rows = @rows.where(user_id: current_user)
      end

      # Aplica filtro por atributo
      if !@project_filters.properties.nil?
        @project_filters.properties.to_a.each do |prop|
          @rows = @rows.where("main.properties->>'" + prop[0] + "' = '#{prop[1]}'")
        end
      end

      # Aplica filtro intercapa
      if !@project_filters.cross_layer_filter_id.nil?

        cross_layer_filter = ProjectFilter.where(user_id: current_user).where(id: @project_filters.cross_layer_filter_id).first

        # Cruza la capa del principal que contiene los hijos con la capa secunadaria
        @rows = @rows
          .joins('INNER JOIN projects sec ON shared_extensions.ST_Intersects(main.the_geom, sec.the_geom)')
          .where('sec.project_type_id = ?', cross_layer_filter.project_type_id)
          .where('sec.row_active = ?', true)
          .where('sec.current_season = ?', true)

        # Aplica filtro por owner a capa secundaria
        if cross_layer_filter.owner == true
          @rows = @rows.where('sec.user_id = ?', current_user)
        end

        # Aplica filtro por atributo a capa secundaria
        if !cross_layer_filter.properties.nil?
          cross_layer_filter.properties.to_a.each do |prop|
            @rows = @rows.where("sec.properties->>'#{prop[0]}' = '#{prop[1]}'")
          end
        end

      end

    end

    @rows = @rows.count
    @rows
  end

end
