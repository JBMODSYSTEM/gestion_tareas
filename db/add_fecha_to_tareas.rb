# db/add_fecha_to_tareas.rb
require 'sqlite3'

DB = SQLite3::Database.new("db/tareas.db")

DB.execute <<-SQL
  ALTER TABLE tareas
  ADD COLUMN fecha TEXT;
SQL
