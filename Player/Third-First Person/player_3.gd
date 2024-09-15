extends CharacterBody3D

var speed : float
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 5.0

@onready var camera1_controller = $CamOrigin/SpringArm3D/Camera3D  # Cámara de primera persona
@onready var camera2_controller = $CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D  # Cámara de tercera persona
@onready var player_model = $Cuerpo  # Modelo del jugador (debe existir este nodo)

const base_fov = 75.0
const fov_change = 1.5

var active_camera = 1  # 1 = tercera persona, 2 = primera persona

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_toggle_cameras()  # Activa la cámara de tercera persona por defecto

func _input(_event):
	if Input.is_action_just_pressed("UI_CamChange"):
		_toggle_cameras()  # Cambia entre las cámaras

func _toggle_cameras():
	if active_camera == 1:
		# Activa la cámara de primera persona y desactiva la de tercera
		camera1_controller.current = true
		camera2_controller.current = false
		active_camera = 2
	else:
		# Activa la cámara de tercera persona y desactiva la de primera
		camera1_controller.current = false
		camera2_controller.current = true
		active_camera = 1

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("UI_Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint
	if Input.is_action_pressed("UI_Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	if Input.is_action_just_pressed("UI_Quit"):
		get_tree().quit()

	# Movimiento del personaje
	var input_dir = Input.get_vector("UI_Rigth","UI_Left","UI_Back","UI_Forward")
	var direction : Vector3 = Vector3.ZERO
	
	# En tercera persona, el movimiento debe seguir la cámara
	if active_camera == 1:
		# Usamos la dirección de la cámara para mover al personaje
		var cam_transform = camera2_controller.global_transform
		var forward = cam_transform.basis.z.normalized()  # Eje Z como "adelante" de la cámara
		var right = cam_transform.basis.x.normalized()  # Eje X como "derecha" de la cámara

		# Invertimos las entradas de movimiento para corregir la rotación y la dirección
		direction = (-right * input_dir.x + -forward * input_dir.y).normalized()

		# Rotar el jugador hacia la dirección de movimiento, solo en el eje Y (invertido)
		if direction.length() > 0:
			var target_rotation = atan2(-direction.x, -direction.z)
			player_model.rotation.y = lerp_angle(player_model.rotation.y, target_rotation, 10 * delta)
	else:
		# En primera persona, el movimiento sigue la dirección de la cámara
		var cam_transform_fp = camera1_controller.global_transform
		var forward_fp = cam_transform_fp.basis.z.normalized()
		var right_fp = cam_transform_fp.basis.x.normalized()

		# El movimiento está alineado con la rotación de la cámara
		direction = (-right_fp * input_dir.x + -forward_fp * input_dir.y).normalized()

		# Rotamos el personaje según la cámara (solo en el eje Y)
		player_model.rotation.y = camera1_controller.global_transform.basis.get_euler().y
	
	# Mover el personaje solo si hay dirección de movimiento
	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	move_and_slide()

	# Ajustar FOV en primera persona
	if active_camera == 2:
		if speed == SPRINT_SPEED:
			var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
			var target_fov = base_fov + fov_change * velocity_clamped
			camera1_controller.fov = lerp(camera1_controller.fov, target_fov, delta * 8)
		else:
			camera1_controller.fov = lerp(camera1_controller.fov, base_fov, delta * 8)
