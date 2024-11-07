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

  # Sobreescribimos el método para mostrar detalles incluyendo la frecuencia
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

  def mostrar_tareas
    @tareas.map(&:mostrar_detalle)
  end
end

# Ruta principal para agregar tarea
get '/' do
  erb :index
end

# Ruta para procesar la creación de una nueva tarea
post '/agregar_tarea' do
  nombre = params[:nombre]
  prioridad = params[:prioridad]
  fecha = params[:fecha]
  tipo = params[:tipo]
  frecuencia = params[:frecuencia]

  # Inicializa la sesión de usuario y sus tareas si no existen
  session[:usuario] ||= Usuario.new("Kev")

  # Crear tarea según el tipo
  tarea = if tipo == 'recurrente'
            TareaRecurrente.new(nombre, prioridad, fecha, frecuencia)
          else
            Tarea.new(nombre, prioridad, fecha)
          end

  # Agregar la tarea al usuario en sesión
  session[:usuario].agregar_tarea(tarea)

  # Redirigir al listado de tareas
  redirect '/tareas'
end

# Ruta para mostrar las tareas
get '/tareas' do
  @usuario = session[:usuario]
  @tareas = @usuario.mostrar_tareas if @usuario
  erb :tareas
end
