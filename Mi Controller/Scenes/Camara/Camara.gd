extends Node3D

@export var camera_target: Node3D
@export var pitch_max = 50
@export var pitch_min = -50
@export var third_person_distance = 5.0  # Distancia de la cámara en tercera persona

var yaw = 0.0
var pitch = 0.0
var yaw_sensitivity = 0.002
var pitch_sensitivity = 0.002

var first_person = false  # Controlador de la vista en primera persona

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	adjust_camera_view()  # Asegurarse de que la cámara esté bien configurada al inicio

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() != 0:
		yaw -= event.relative.x * yaw_sensitivity
		pitch -= event.relative.y * pitch_sensitivity  # Invertir el eje vertical
		pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))

	if Input.is_action_just_pressed("UI_CamChange"):
		first_person = not first_person
		adjust_camera_view()

func _physics_process(delta):
	camera_target.rotation.y = lerp(camera_target.rotation.y, yaw, delta * 10)
	camera_target.rotation.x = lerp(camera_target.rotation.x, pitch, delta * 10)

func adjust_camera_view():
	var spring_arm = $CamaraTarget/SpringArm3D  # Ajusta esta línea si la ruta es diferente

	# Verifica si el nodo de SpringArm3D existe
	if spring_arm:
		if first_person:
			# Vista en primera persona: mueve el SpringArm3D cerca del jugador
			spring_arm.position = Vector3(0, 0, 0)
			print("Cambiado a primera persona")
		else:
			# Vista en tercera persona: mueve el SpringArm3D hacia atrás
			spring_arm.position = Vector3(0, 1.5, -third_person_distance)  # Ajusta la posición para tercera persona
			print("Cambiado a tercera persona")
	else:
		print("SpringArm3D no encontrado. Asegúrate de que el nodo está correctamente nombrado.")
