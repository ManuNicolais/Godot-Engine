extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5

#rebote de cabeza (funcion sen/cos)
const bote_freq = 2.0
const bote_ampli = 0.08
var t_bote = 0.0

const base_fov = 75.0
const fov_change = 1.5 

@onready var pivot = $CamOrigin
@onready var camara = $CamOrigin/SpringArm3D/Camera3D
@export var sens = 0.05

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(60))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("UI_Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Mantener Correr
	if Input.is_action_pressed("UI_Sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
		
	if Input.is_action_just_pressed("UI_Quit"):
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("UI_Left", "UI_Rigth", "UI_Forward", "UI_Back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():#para no detener el salto en el aire
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else: 
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
			
	#botar de camara implementacion
	t_bote += delta * velocity.length() * float(is_on_floor())
	camara.transform.origin = _botarCabeza(t_bote)
	
	#FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camara.fov = lerp(camara.fov, target_fov, delta * 8.0)
	
	

	move_and_slide()

func _botarCabeza(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin (time * bote_freq) * bote_ampli
	pos.x = cos(time * bote_freq / 2) * bote_ampli
	
	return pos
