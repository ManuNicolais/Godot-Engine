extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5

@onready var camera1_controller = $CamOrigin/SpringArm3D/Camera3D  # Referencia para la cámara en primera persona
@onready var camera2_controller = $CamRoot/CamYaw/CamPitch/SpringArm3D/Camera3D    # Cámara en tercera persona

const base_fov = 75.0
const fov_change = 1.5 

var active_camera = 2 # 2 indica primera persona, 1 indica tercera persona

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_toggle_cameras()  # Activar la cámara 1 por defecto
	
func _input(event):
	if Input.is_action_just_pressed("UI_CamChange"):
		_toggle_cameras()  # Cambiar entre las cámaras

func _toggle_cameras():
	if active_camera == 1:
		# Desactivar cámara 1 y activar cámara 2
		camera1_controller.current = false
		camera2_controller.current = true
		active_camera = 2
	else:
		# Desactivar cámara 2 y activar cámara 1
		camera2_controller.current = false
		camera1_controller.current = true
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
	var input_dir = Input.get_vector("UI_Left", "UI_Rigth", "UI_Forward", "UI_Back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(float(velocity.x), 0.0, delta * 7.0)
			velocity.z = lerp(float(velocity.z), 0.0, delta * 7.0)
	else: 
		velocity.x = lerp(float(velocity.x), direction.x * speed, delta * 3.0)
		velocity.z = lerp(float(velocity.z), direction.z * speed, delta * 3.0)
	
	# Ajuste del FOV solo cuando la cámara en primera persona está activa
	if active_camera == 1:
		if speed == SPRINT_SPEED:
			var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
			var target_fov = base_fov + fov_change * velocity_clamped
			camera1_controller.fov = lerp(camera1_controller.fov, target_fov, delta * 8.0)
		else:
			camera1_controller.fov = lerp(camera1_controller.fov, base_fov, delta * 8.0)
	
	move_and_slide()
