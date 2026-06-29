extends Area3D

@export var text: String
@export var image: Texture2D # not currently used

var triggered = false

func _on_body_entered(body: Node3D) -> void:
	if triggered: return
	if body and body is CharacterBody3D:
		var player = body
		player.showing_prompt = true
		player.prompt.text = text
		triggered = true
