require 'sinatra'
require 'sinatra/reloader' if development?

# Configura la carpeta 'public' para archivos estáticos (CSS, imágenes, etc.)
set :public_folder, 'public'
enable :sessions  # Habilita sesiones para almacenar datos específicos de cada usuario

# Clase Tarea
class Tarea
  attr_accessor :nombre, :prioridad, :fecha, :completada

  def initialize(nombre, prioridad, fecha)
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

  def initialize(nombre, prioridad, fecha, frecuencia)
    super(nombre, prioridad, fecha)
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
    @tareas << tarea
  end

  def editar_tarea(id, nombre, prioridad, fecha, tipo, frecuencia = nil)
    tarea = @tareas[id.to_i]
    tarea.nombre = nombre
    tarea.prioridad = prioridad
    tarea.fecha = fecha
    if tipo == "recurrente" && tarea.is_a?(TareaRecurrente)
      tarea.frecuencia = frecuencia
    elsif tipo == "normal" && tarea.is_a?(TareaRecurrente)
      @tareas[id.to_i] = Tarea.new(nombre, prioridad, fecha)
    elsif tipo == "recurrente" && tarea.is_a?(Tarea)
      @tareas[id.to_i] = TareaRecurrente.new(nombre, prioridad, fecha, frecuencia)
    end
  end

  def mostrar_tareas
    @tareas.map(&:mostrar_detalle)
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

  tarea = if tipo == 'recurrente'
            TareaRecurrente.new(nombre, prioridad, fecha, frecuencia)
          else
            Tarea.new(nombre, prioridad, fecha)
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
  @tarea = @usuario.tareas[@id]
  erb :editar_tarea
end

# Ruta para eliminar una tarea
post '/tareas/:id/eliminar' do
    redirect '/' unless session[:usuario]
  
    @usuario = session[:usuario]
    id = params[:id].to_i
    @usuario.tareas.delete_at(id)  # Elimina la tarea de la lista
    redirect '/tareas'
  end

# Ruta para procesar la edición de una tarea
post '/tareas/:id/editar' do
  # Asegura que session[:usuario] esté inicializada
  redirect '/' unless session[:usuario]

  @usuario = session[:usuario]
  id = params[:id]
  nombre = params[:nombre]
  prioridad = params[:prioridad]
  fecha = params[:fecha]
  tipo = params[:tipo]
  frecuencia = params[:frecuencia]

  @usuario.editar_tarea(id, nombre, prioridad, fecha, tipo, frecuencia)
  redirect '/tareas'
end
