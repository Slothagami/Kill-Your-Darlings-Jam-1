extends Area2D

@export var speed: float = 700.0
@export var lifetime: float = 3.6
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("fish"):
		area.hit(damage)
		queue_free()
