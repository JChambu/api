# cronotab.rb — Crono configuration file
#
# Here you can specify periodic jobs and schedule.
# You can use ActiveJob's jobs from `app/jobs/`
# You can use any class. The only requirement is that
# class should have a method `perform` without arguments.
#
# class TestJob
#   def perform
#     puts 'Test!'
#   end
# end
#
# Crono.perform(TestJob).every 2.days, at: '15:30'

class ResetInheritableStatuses
  def perform
    Project.reset_inheritable_statuses
  end
end

class DisableRecords
  def perform
    Project.disable_records
  end
end

Crono.perform(ResetInheritableStatuses).every 1.day, at: {hour: 0, min: 0}
Crono.perform(DisableRecords).every 1.day, at: {hour: 0, min: 0}
