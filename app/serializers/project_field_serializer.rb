class ProjectFieldSerializer < ActiveModel::Serializer
  attributes :id, :name, :field_type, :project_type_id,:key
end
