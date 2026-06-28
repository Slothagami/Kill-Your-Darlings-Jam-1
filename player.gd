extends CharacterBody3D

const SPEED         = 11.0
const JUMP_VELOCITY = 4.5
const PUNCH_FORCE   = 5
const sensitivity   = 0.005

const HIT_POINTS    = 100
const AIR_HIT_BOOST = 5.0
const BOX_MAX_HITS = 5

const GRAB_RANGE = 1000.0
const GRAB_MAX_SPEED = 30.0
const GRAB_STOP_DISTANCE = 2.0

const MAX_PLAYER_SPEED = 20.0			# basically terminal velocity
const MAX_UPWARD_SPEED = 10.0
const MAX_DOWNWARD_SPEED = -5.0

var in_grab_state = false
var grab_start_pos:  Vector3
var grab_target_pos: Vector3
var grab_time

var score = 0
var combo = 0
var best_combo = 0

@onready var camera     = $camera
@onready var sight_ray  = $camera/sight_ray
@onready var grab_ray   = $camera/grab_ray
@onready var grab_timer = $grab_timer
@onready var score_text = $HUD/ScoreLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	grab_time = grab_timer.wait_time
	grab_ray.target_position = Vector3(0, 0, -GRAB_RANGE)
	update_score_text()


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
		
	if Input.is_action_just_pressed("grab"):
		# Cast a ray to find the nearest physics body and launch the player towards it
		if grab_ray.is_colliding():
			var target = grab_ray.get_collider()
			if target is RigidBody3D:
				# lerp the players position to a specified distance
				# away from the enemy in a fixed ammount of time
				in_grab_state = true 
				grab_start_pos = position
				grab_target_pos = target.position
				grab_timer.start()

		
	if Input.is_action_just_pressed("attack"):
		# Cast a ray to find the nearest physics body and apply a force
		if sight_ray.is_colliding():
			var target = sight_ray.get_collider()
			
			if target is RigidBody3D:
				target.apply_impulse(
					transform.basis * Vector3(0, 0, -1) * PUNCH_FORCE,
					sight_ray.get_collision_point()
				)

				score_hit()
				damage_box(target)
				
				# Only give points once per box, so the player can't farm one box forever.
				#if not target.get_meta("already_scored", false):
				#	target.set_meta("already_scored", true)
				#	score_hit()

	# Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	# Grab state overrides controls
	if in_grab_state:
		var displacement = grab_target_pos - global_position
		var desired_velocity = displacement / max(grab_timer.time_left, 0.1)
		
		if desired_velocity.length() > GRAB_MAX_SPEED:
			desired_velocity = desired_velocity.normalized() * GRAB_MAX_SPEED
		
		velocity = desired_velocity
		
		if global_position.distance_to(grab_target_pos) < 0.5:
			in_grab_state = false
	
	velocity.y = clamp(velocity.y, MAX_DOWNWARD_SPEED, MAX_UPWARD_SPEED)

	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length() > MAX_PLAYER_SPEED:
		horizontal_velocity = horizontal_velocity.normalized() * MAX_PLAYER_SPEED
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

	move_and_slide()

	# break combo if on ground
	if combo > 0 and is_on_floor() and standing_on_ground():
		combo = 0
		update_score_text()


func standing_on_ground() -> bool:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider != null and collider.is_in_group("ground"):
			return true
	
	return false


func score_hit() -> void:
	if is_on_floor():
		score += HIT_POINTS
	else:
		combo += 1
		best_combo = max(best_combo, combo)
		score += HIT_POINTS * combo
		
		# Small boost to keep player in air
		velocity.y = max(velocity.y, AIR_HIT_BOOST)

	update_score_text()


func damage_box(target: RigidBody3D) -> void:
	var hits_taken = int(target.get_meta("hits_taken", 0)) + 1
	target.set_meta("hits_taken", hits_taken)

	#change box colour on taking damage
	var grey = 1.0 - float(hits_taken) / float(BOX_MAX_HITS)
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(grey, grey, grey)

	target.get_node("MeshInstance3D").material_override = material

	print("Box hit: ", hits_taken, "/", BOX_MAX_HITS)

	#despawn box
	if hits_taken >= BOX_MAX_HITS:
		target.queue_free()


func update_score_text() -> void:
	if score_text == null:
		return
	
	score_text.text = "Score: " + str(score)
	score_text.text += "\nCombo: x" + str(combo)
	score_text.text += "\nBest Combo: x" + str(best_combo)


func _on_grab_animation_finish() -> void:
	in_grab_state = false
