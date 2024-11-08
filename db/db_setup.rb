require 'sqlite3'

# Conectar a la base de datos
DB = SQLite3::Database.new 'db/tareas.db'

# Crear tabla tareas si no existe
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS tareas (
    id INTEGER PRIMARY KEY,
    nombre TEXT,
    prioridad TEXT,
    fecha TEXT,
    completada BOOLEAN,
    frecuencia TEXT
  );
SQL

puts "Tabla 'tareas' creada exitosamente"
