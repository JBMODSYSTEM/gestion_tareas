require 'sinatra'
require 'sinatra/reloader' if development?

# Configura la carpeta 'public' para archivos estáticos (CSS, imágenes, etc.)
set :public_folder, 'public'

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

# Ejemplo de usuario y tareas
usuario = Usuario.new("Kev")
tarea1 = Tarea.new("Responder correos", "Alta", "2024-11-06")
tarea2 = TareaRecurrente.new("Estudiar programación", "Media", "2024-11-06", "Diaria")

usuario.agregar_tarea(tarea1)
usuario.agregar_tarea(tarea2)

# Ruta principal para agregar tarea
get '/' do
  erb :index
end

# Ruta para mostrar las tareas
get '/tareas' do
  @usuario = usuario
  @tareas = @usuario.mostrar_tareas
  erb :tareas
end
