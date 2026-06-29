extends Control

@export var game_scene_path = "res://world.tscn"

@onready var start_button = $"Background/CenterContainer/VBoxContainer/StartButton"
@onready var quit_button = $"Background/CenterContainer/VBoxContainer/QuitButton"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	start_button.pressed.connect(start_game)
	quit_button.pressed.connect(quit_game)


func start_game() -> void:
	get_tree().change_scene_to_file("res://world.tscn")


func quit_game() -> void:
	get_tree().quit()
