extends CharacterBody3D

const SPEED         = 5.0
const JUMP_VELOCITY = 4.5
const PUNCH_FORCE   = 5
const sensitivity   = 0.005

var in_grab_state = false
var grab_start_pos:  Vector3
var grab_target_pos: Vector3
var grabbing: RigidBody3D = null

var hit_angle = PI/2
var hit_strength = PUNCH_FORCE

@onready var camera     = $camera
@onready var sight_ray  = $camera/sight_ray
@onready var grab_node  = $camera/grab_node

@onready var crosshair       = $crosshair
@onready var force_indicator = $force_indicator
@onready var force_guage     = $force_indicator/guage

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		self.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Controls
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if Input.is_action_just_pressed("adjust_up"):
		if Input.is_action_pressed("modifier_key"):
			hit_strength -= .25
		else:
			hit_angle += 2*PI / 20
	if Input.is_action_just_pressed("adjust_down"):
		if Input.is_action_pressed("modifier_key"):
			hit_strength += .25
		else:
			hit_angle -= 2*PI / 20
			
	hit_strength = clamp(hit_strength, 0.25, 10)
	
	if Input.is_action_just_pressed("grab"):
		if grabbing == null:
			if sight_ray.is_colliding():
				var target = sight_ray.get_collider()
				if target is RigidBody3D:
					grabbing = target
		else:
			grabbing = null
		
	if Input.is_action_just_pressed("attack"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		# Cast a ray to find the nearest physics body and apply a force
		if sight_ray.is_colliding():
			var target = sight_ray.get_collider()
			var hit_dir = Vector3.FORWARD.rotated(Vector3.UP, PI/2 * .8).rotated(Vector3.FORWARD, hit_angle)
			if target is RigidBody3D:
				target.apply_impulse(
					transform.basis * hit_dir * hit_strength, 
					sight_ray.get_collision_point() - target.global_position
				)

	# Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# picking up boxes
	if grabbing != null:
		grabbing.global_position = grab_node.global_position
		
	# update ui
	force_indicator.rotation = hit_angle
	force_guage.scale.x = 4 * hit_strength
	
	if sight_ray.is_colliding():
		crosshair.scale = Vector2(0.15, 0.15)
	else:
		crosshair.scale = Vector2(0.1, 0.1)
	
	move_and_slide()
