extends Control

@export var main_menu_path = "res://scenes/main_menu.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	$CenterContainer/PanelContainer/VBoxContainer/MusicVolumeSlider.set_value_no_signal(MusicManager.music_volume)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()


func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED


func _on_resume_button_pressed() -> void:
	toggle_pause()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_music_volume_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)
