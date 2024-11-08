require 'sqlite3'

DB = SQLite3::Database.new 'db/tareas.db'
DB.results_as_hash = true

# Crea la tabla de tareas si no existe
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
