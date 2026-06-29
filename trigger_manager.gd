extends Node3D

@export  var target: Node3D
@onready var timer = $timer

func _process(delta: float) -> void:
	# trigger the script if all children triggers are satisfied
	var colliding = true
	var children  = get_children()
	for trigger in children:
		if trigger is not Timer:
			colliding = colliding and trigger.colliding
		
	# resets the timer every frame that the conditions aren't met, timer only finishes if stack 
	# stays stable for the duration of the timer
	if not colliding:
		timer.start()


func _on_timer_timeout() -> void:
	target.queue_free()
	queue_free()
