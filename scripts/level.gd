extends Node2D

@export var fish_scene: PackedScene

@onready var rod_origin: Marker2D = $RodOrigin
@onready var rod_line: Line2D = $RodLine
@onready var gun: Node2D = $Gun
@onready var fish_container: Node2D = $FishContainer
@onready var spawn_timer: Timer = $FishSpawnTimer
@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var camera: Camera2D = $Camera2D
@onready var darkness: ColorRect = $CanvasLayer/Darkness

var rod_length: float = 120.0
var min_length: float = 60.0
var max_length: float = 2560.0
var rod_speed: float = 260.0

var carried_money: int = 0
var banked_money: int = 0

var fish_spawn_margin: float = 300.0

func _ready() -> void:
	add_to_group("score_manager")
	spawn_timer.timeout.connect(spawn_fish)
	update_hud()


func _process(delta: float) -> void:
	handle_rod_movement(delta)
	update_gun_position()
	update_rod_line()
	update_camera()
	update_darkness()
	check_surface_banking()
	update_hud()

# find camera borders
func get_camera_rect() -> Rect2:
	var viewport_size: Vector2 = get_viewport_rect().size
	var visible_size: Vector2 = viewport_size / camera.zoom
	var top_left: Vector2 = camera.global_position - visible_size * 0.5

	return Rect2(top_left, visible_size)

# move camera
func update_camera() -> void:
	camera.global_position.x = gun.global_position.x
	camera.global_position.y = lerpf(camera.global_position.y, gun.global_position.y, 0.08)

func handle_rod_movement(delta: float) -> void:
	if Input.is_action_pressed("lower_rod"):
		rod_length += rod_speed * delta

	if Input.is_action_pressed("raise_rod"):
		rod_length -= rod_speed * delta

	rod_length = clampf(rod_length, min_length, max_length)


func update_gun_position() -> void:
	gun.global_position = rod_origin.global_position + Vector2(0, rod_length)


func update_rod_line() -> void:
	rod_line.clear_points()
	rod_line.add_point(rod_line.to_local(rod_origin.global_position))
	rod_line.add_point(rod_line.to_local(gun.global_position))


func spawn_fish() -> void:
	if fish_scene == null:
		return

	var fish = fish_scene.instantiate()
	fish_container.add_child(fish)

	var camera_rect: Rect2 = get_camera_rect()
	var from_left: bool = randf() < 0.5

	if from_left:
		fish.global_position.x = camera_rect.position.x - fish_spawn_margin
		fish.direction = 1
	else:
		fish.global_position.x = camera_rect.position.x + camera_rect.size.x + fish_spawn_margin
		fish.direction = -1

	fish.global_position.y = randf_range(
		camera_rect.position.y + 80.0,
		camera_rect.position.y + camera_rect.size.y - 80.0
	)

	var depth_percent: float = get_depth_percent()

	# make fish more difficult at lower depths
	fish.speed = randf_range(80.0, 180.0 + depth_percent * 120.0)
	fish.value = 1 + int(depth_percent * 5.0)

	if "health" in fish:
		fish.health = 1 + int(depth_percent * 4.0)

	if "damage" in fish:
		fish.damage = 1 + int(depth_percent * 3.0)


func add_score(amount: int) -> void:
	carried_money += amount


func check_surface_banking() -> void:
	if rod_length <= min_length + 5.0 and carried_money > 0:
		banked_money += carried_money
		carried_money = 0


func get_depth() -> int:
	return int(rod_length - min_length)


func get_depth_percent() -> float:
	return clampf(inverse_lerp(min_length, max_length, rod_length), 0.0, 1.0)


func update_hud() -> void:
	var gun_type: String = "gun"
	var ammo_text: String = ""

	if gun.has_method("get_gun_type"):
		gun_type = gun.get_gun_type()

	if gun.has_method("get_ammo_text"):
		ammo_text = gun.get_ammo_text()

	score_label.text = "Depth: %dm  Money: $%d  Carrying: $%d  Gun: %s  Ammo: %s" % [
		get_depth(),
		banked_money,
		carried_money,
		gun_type,
		ammo_text
	]

# make level get darker at lower depths
func update_darkness() -> void:
	var depth_percent: float = get_depth_percent()

	var max_darkness: float = 0.75
	var alpha: float = lerpf(0.0, max_darkness, depth_percent)

	darkness.color = Color(0.0, 0.02, 0.08, alpha)
