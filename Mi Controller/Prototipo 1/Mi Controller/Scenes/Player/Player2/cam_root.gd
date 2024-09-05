extends Node3D

signal set_cam_rotation(_cam_rotation : float)

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var camera = $CamYaw/CamPitch/SpringArm3D/Camera3D

var yaw : float = 0
var pitch : float = 0

var yawSensitivity : float = 0.07
var pitchSensitivity : float = 0.07	

var yawAcceleration : float = 15
var pitchAcceleration : float = 15

var pitch_max : float = 85
var pitch_min : float = -55

func _unhandled_input(_event):
	if Input.is_action_just_pressed("UI_Quit"):
		get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yawSensitivity
		pitch += -event.relative.y * pitchSensitivity

func _physics_process(_delta):
	pitch = clamp(pitch, pitch_min, pitch_max)
	
	#smooth camera
	#yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yawAcceleration * delta)
	#pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitchAcceleration * delta)
	
	yaw_node.rotation_degrees.y = yaw
	pitch_node.rotation_degrees.x = pitch
	
	set_cam_rotation.emit(yaw_node.rotation.y)
