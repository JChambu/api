class ProjectField < ApplicationRecord

  belongs_to :project_type
  belongs_to :regexp_type
end
