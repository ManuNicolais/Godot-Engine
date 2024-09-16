extends Node3D

@export var yawSensitivity : float = 0.07
@export var pitchSensitivity : float = 0.07	

var yaw : float = 0
var pitch : float = 0

var yawAcceleration : float = 15
var pitchAcceleration : float = 15

var pitch_max : float = 85
var pitch_min : float = -55

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch

func _input(event):
	if event is InputEventMouseMotion:
		# Rotación de la cámara en tercera persona
		yaw += -event.relative.x * yawSensitivity
		pitch += -event.relative.y * pitchSensitivity

func _process(delta):
	# Limitar pitch y suavizar la rotación
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yawAcceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitchAcceleration * delta)
