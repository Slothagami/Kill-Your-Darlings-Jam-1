extends GPUParticles3D

@export var lidar_camera: Camera3D
@export var mic_input: Node

@export var min_amount_ratio: float = 0.0
@export var max_amount_ratio: float = 0.5


func _ready() -> void:
	lidar_camera.compositor.compositor_effects[0].texture_generated.connect(_on_texture_generated)


func _on_texture_generated(in_position_texture: Texture2DRD) -> void:
	process_material.set_shader_parameter("position_texture", in_position_texture)


func _process(_delta: float) -> void:
	var mic_is_talking: bool = false
	var mic_volume: float = 0.0

	if mic_input != null:
		mic_is_talking = mic_input.is_talking
		mic_volume = mic_input.volume_amount

	var manual_scan: bool = Input.is_action_pressed("LMB")
	var scan_active: bool = manual_scan or mic_is_talking

	emitting = scan_active

	if scan_active:
		var scan_strength: float = mic_volume

		if manual_scan:
			scan_strength = 1.0

		amount_ratio = lerpf(min_amount_ratio, max_amount_ratio, scan_strength)
	else:
		amount_ratio = 0.0
