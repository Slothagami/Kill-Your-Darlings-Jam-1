extends Camera3D

@export var camera_to_follow: Camera3D


func _process(_delta: float) -> void:
	# We follow the player's camer every frame
	global_transform = camera_to_follow.global_transform;
