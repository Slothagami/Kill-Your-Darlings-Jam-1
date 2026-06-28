extends Area2D

@onready var visual: Polygon2D = $Polygon2D

@export var speed: float = 120.0
@export var value: int = 1
@export var health: int = 1
@export var damage: int = 1

var direction: int = 1
var original_visual_scale: Vector2



func _ready() -> void:
	add_to_group("fish")
	original_visual_scale = visual.scale
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta

	if direction > 0:
		visual.scale.x = absf(original_visual_scale.x)
	else:
		visual.scale.x = -absf(original_visual_scale.x)

	visual.scale.y = original_visual_scale.y

	var screen_width: float = get_viewport_rect().size.x

	var camera := get_viewport().get_camera_2d()

	if camera != null:
		if global_position.distance_to(camera.global_position) > 1400.0:
			queue_free()


func hit(amount: int = 1) -> void:
	health -= amount
	print("Fish hit. Remaining health: ", health)

	if health <= 0:
		get_tree().call_group("score_manager", "add_score", value)
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("gun_hurtbox"):
		get_tree().call_group("level", "damage_gun", damage)
		queue_free()
