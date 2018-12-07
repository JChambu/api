class ProjectFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :field_type_id, :project_type_id, :key, :required, :items

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

end