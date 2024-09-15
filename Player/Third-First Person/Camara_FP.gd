extends Node3D

@export var sensitivity : float = 0.07
var yaw : float = 0.0
var pitch : float = 0.0

@onready var spring_arm = $SpringArm3D  # Referencia al nodo SpringArm3D

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * sensitivity
		pitch += -event.relative.y * sensitivity
		pitch = clamp(pitch, -90.0, 90.0)  # Limitar el pitch

func _process(_delta):
	spring_arm.rotation_degrees.y = yaw
	spring_arm.rotation_degrees.x = pitch
