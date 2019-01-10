class Project < ApplicationRecord
  require 'rgeo/shapefile'
  require 'rgeo/geo_json'

  belongs_to :project_type
  has_many :photos
  accepts_nested_attributes_for :photos


  def self.show_data data

    project = []
    data.properties.each do |item|

      @pf = ProjectField.where(project_type_id: data.project_type_id).where(name: item[0]).where(hidden: false).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id )
      if !@pf.empty?
        @choice_list_item = ''
        if !@pf[0].choice_list_id.nil?
          @choice_list_item = show_choice_list(@pf[0].choice_list_id)
        end
        @regexp =''
        if !@pf[0].regexp_type_id.nil?
          @regexp = show_regexp_type(@pf[0].regexp_type_id)
        end

        @value = item[1]
        if @pf[0].field_type_id == 7
          @subvalue = []
          item[1].each do |subitem|
            @su = subitem
            subitem.each do |element|
              @e = element
              @repetible = ProjectSubfield.where(project_field_id: @pf[0].id).where(name: element[0]).select(:id, :name, :field_type_id , :required, :choice_list_id, :regexp_type_id )

              @choice_list_subitem = '' 
              if !@pf[0].choice_list_id.nil?
                @choice_list_subitem = show_choice_list(@pf[0].choice_list_id)
              end
              @regexp =''
              if !@pf[0].regexp_type_id.nil?
                @regexp_subitem = show_regexp_type(@pf[0].regexp_type_id)
              end

              @repetible  += [items: @choice_list_subitem]
              @repetible  += [regexp: @regexp_subitem]
              @repetible  += [value: element[1]]



              @subvalue += @repetible
            end
          end

          @value = subvalue
        end
        @pf +=[items: @choice_list_item]
        @pf +=[regexp: @regexp]
        @pf += [value: @value]

        project.push @pf
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
