# db/add_fecha_to_tareas.rb
require 'sqlite3'

# Conectar a la base de datos
DB = SQLite3::Database.new("db/tareas.db")

# Agregar la columna 'fecha' a la tabla 'tareas'
DB.execute <<-SQL
  ALTER TABLE tareas
  ADD COLUMN fecha TEXT;
SQL
