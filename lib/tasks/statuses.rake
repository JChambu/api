namespace :statuses do
  desc 'Vuelve los estados heredables a su valor predeterminado'

  # Tarea que invoca arask
  task reset: :environment do
    Rake::Task['statuses:reset_statuses'].execute
  end

  # Ejecuta el metodo y habilita la tarea que invoca arask nuevamente
  task reset_statuses: :environment do
    Project.reset_inheritable_statuses
    Rake::Task['statuses:reset'].reenable
  end
end
