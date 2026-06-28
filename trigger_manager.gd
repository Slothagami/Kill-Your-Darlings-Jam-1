extends Node3D

@export  var target: Node3D
@onready var timer = $timer

func _process(delta: float) -> void:
	# trigger the script if all children triggers are satisfied
	var bodies = []
	var children = get_children()
	for trigger in children:
		if trigger is Area3D:
			bodies += trigger.get_overlapping_bodies()
		
	bodies = remove_duplicates(bodies)
		
	if not len(bodies) == len(children) - 1: # if each trigger has a unique box
		# resets the timer every frame that the conditions aren't met, timer only finishes if stack 
		# stays stable for the duration of the timer
		timer.start()
		


func remove_duplicates(list):
	var new_list = []
	for item in list:
		if not new_list.has(item):
			new_list.append(item)
			
	return new_list


func _on_timer_timeout() -> void:
	target.queue_free()
	queue_free()
