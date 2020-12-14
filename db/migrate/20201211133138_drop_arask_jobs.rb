class DropAraskJobs < ActiveRecord::Migration[5.1]
  def change
    drop_table :arask_jobs
  end
end
