extends Control

@export var game_scene_path = "res://scenes/world.tscn"

@onready var start_button = $"Background/CenterContainer/VBoxContainer/StartButton"
@onready var quit_button = $"Background/CenterContainer/VBoxContainer/QuitButton"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	start_button.pressed.connect(start_game)
	quit_button.pressed.connect(quit_game)
	
	$Background/CenterContainer/VBoxContainer/MusicVolumeSlider.set_value_no_signal(MusicManager.music_volume)


func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func quit_game() -> void:
	get_tree().quit()


func _on_music_volume_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)
