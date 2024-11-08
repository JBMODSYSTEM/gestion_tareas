require 'sinatra'
require 'sinatra/reloader' if development?

require 'sqlite3'
DB = SQLite3::Database.new 'db/tareas.db'
DB.results_as_hash = true

# Configura la carpeta 'public' para archivos estáticos (CSS, imágenes, etc.)
set :public_folder, 'public'
enable :sessions  # Habilita sesiones para almacenar datos específicos de cada usuario

# Clase Tarea
class Tarea
  attr_accessor :id, :nombre, :prioridad, :fecha, :completada

  def initialize(id, nombre, prioridad, fecha)
    @id = id
    @nombre = nombre
    @prioridad = prioridad
    @fecha = fecha
    @completada = false
  end

  def marcar_completada
    @completada = true
  end

  def mostrar_detalle
    "Tarea: #{@nombre}, Prioridad: #{@prioridad}, Fecha: #{@fecha}, Completada: #{@completada}"
  end
end

# Clase TareaRecurrente que hereda de Tarea
class TareaRecurrente < Tarea
  attr_accessor :frecuencia

  def initialize(id, nombre, prioridad, fecha, frecuencia)
    super(id, nombre, prioridad, fecha)
    @frecuencia = frecuencia
  end

  def mostrar_detalle
    super + ", Frecuencia: #{@frecuencia}"
  end
end

# Clase Usuario
class Usuario
  attr_accessor :nombre, :tareas

  def initialize(nombre)
    @nombre = nombre
    @tareas = []
  end

  def agregar_tarea(tarea)
    DB.execute("INSERT INTO tareas (nombre, prioridad, fecha, completada, frecuencia)
                VALUES (?, ?, ?, ?, ?)",
               [tarea.nombre, tarea.prioridad, tarea.fecha, tarea.completada ? 1 : 0, tarea.is_a?(TareaRecurrente) ? tarea.frecuencia : nil])
  end

  def editar_tarea(id, nombre, prioridad, fecha, tipo, frecuencia = nil)
    if tipo == "recurrente"
      DB.execute("UPDATE tareas SET nombre = ?, prioridad = ?, fecha = ?, frecuencia = ? WHERE id = ?",
                 [nombre, prioridad, fecha, frecuencia, id])
    else
      DB.execute("UPDATE tareas SET nombre = ?, prioridad = ?, fecha = ?, frecuencia = NULL WHERE id = ?",
                 [nombre, prioridad, fecha, id])
    end
  end

  def mostrar_tareas
    @tareas = DB.execute("SELECT * FROM tareas").map do |row|
      if row["frecuencia"]
        TareaRecurrente.new(row["id"], row["nombre"], row["prioridad"], row["fecha"], row["frecuencia"]).tap do |t|
          t.completada = row["completada"] == 1
        end
      else
        Tarea.new(row["id"], row["nombre"], row["prioridad"], row["fecha"]).tap do |t|
          t.completada = row["completada"] == 1
        end
      end
    end
  end

  def eliminar_tarea(id)
    DB.execute("DELETE FROM tareas WHERE id = ?", id)
  end
end

# Ruta principal para agregar tarea
get '/' do
  # Inicializa la sesión si no existe
  session[:usuario] ||= Usuario.new("Kev")
  erb :index
end

# Ruta para procesar la creación de una nueva tarea
post '/agregar_tarea' do
  # Asegurarse de que session[:usuario] esté inicializada
  session[:usuario] ||= Usuario.new("Kev")
  
  nombre = params[:nombre]
  prioridad = params[:prioridad]
  fecha = params[:fecha]
  tipo = params[:tipo]
  frecuencia = params[:frecuencia]

  if tipo == 'recurrente' && frecuencia.empty?
    @error = 'La frecuencia es requerida para tareas recurrentes'
    return erb :index
  end

  tarea = if tipo == 'recurrente'
            TareaRecurrente.new(nil, nombre, prioridad, fecha, frecuencia)
          else
            Tarea.new(nil, nombre, prioridad, fecha)
          end

  session[:usuario].agregar_tarea(tarea)
  redirect '/tareas'
end

# Ruta para mostrar las tareas
get '/tareas' do
  # Asegura que session[:usuario] esté inicializada
  redirect '/' unless session[:usuario]

  @usuario = session[:usuario]
  @tareas = @usuario.mostrar_tareas
  erb :tareas
end

# Ruta para editar una tarea
get '/tareas/:id/editar' do
  # Asegura que session[:usuario] esté inicializada
  redirect '/' unless session[:usuario]

  @usuario = session[:usuario]
  @id = params[:id].to_i
  @tarea = @usuario.mostrar_tareas.find { |t| t.id == @id }

  halt(404, 'Tarea no encontrada') unless @tarea

  erb :editar_tarea
end

# Ruta para eliminar una tarea
post '/tareas/:id/eliminar' do
  redirect '/' unless session[:usuario]

  @usuario = session[:usuario]
  id = params[:id].to_i
  halt(404, 'Tarea no encontrada') unless @usuario.mostrar_tareas.any? { |t| t.id == id }

  @usuario.eliminar_tarea(id)  # Elimina la tarea de la base de datos
  redirect '/tareas'
end

# Ruta para procesar la edición de una tarea
post '/tareas/:id/editar' do
  # Asegura que session[:usuario] esté inicializada
  redirect '/' unless session[:usuario]

  @usuario = session[:usuario]
  id = params[:id].to_i
  nombre = params[:nombre]
  prioridad = params[:prioridad]
  fecha = params[:fecha]
  tipo = params[:tipo]
  frecuencia = params[:frecuencia]

  @usuario.editar_tarea(id, nombre, prioridad, fecha, tipo, frecuencia)
  redirect '/tareas'
end
