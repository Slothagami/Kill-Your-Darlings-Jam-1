extends CharacterBody3D

@export var move_speed: float = 3.0
@export var mouse_sensitivity: float = 0.003
@export var gravity: float = 20.0
@export var jump_velocity: float = 6.0

@onready var camera: Camera3D = $Camera3D

var yaw: float = 0.0
var pitch: float = 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clampf(pitch, deg_to_rad(-80.0), deg_to_rad(80.0))

		rotation.y = yaw
		camera.rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var forward: Vector3 = -global_transform.basis.z
	var right: Vector3 = global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var direction: Vector3 = (right * input_dir.x + forward * -input_dir.y).normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		else:
			velocity.y = 0.0

	move_and_slide()
