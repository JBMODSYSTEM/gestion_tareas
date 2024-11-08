require 'sqlite3'

# Conectar a la base de datos
DB = SQLite3::Database.new 'db/tareas.db'

# Agregar la columna 'prioridad' a la tabla 'tareas' si no existe
begin
  DB.execute("ALTER TABLE tareas ADD COLUMN prioridad TEXT")
  puts "Columna 'prioridad' agregada a la tabla 'tareas'"
rescue SQLite3::SQLException => e
  puts "Error: #{e.message}"
end
