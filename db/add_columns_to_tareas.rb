# db/add_columns_to_tareas.rb
require 'sqlite3'

# Conectar a la base de datos
DB = SQLite3::Database.new("db/tareas.db")

# Agregar columnas a la tabla tareas
DB.execute <<-SQL
  ALTER TABLE tareas
  ADD COLUMN prioridad INTEGER;
SQL

DB.execute <<-SQL
  ALTER TABLE tareas
  ADD COLUMN fecha TEXT;
SQL

DB.execute <<-SQL
  ALTER TABLE tareas
  ADD COLUMN completada BOOLEAN;
SQL

DB.execute <<-SQL
  ALTER TABLE tareas
  ADD COLUMN frecuencia TEXT;
SQL
