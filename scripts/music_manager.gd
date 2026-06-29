extends Node

const MUSIC_PATH = "res://audio/music/poradovskyi-cozy-chill-lounge-music-469048.mp3"

var music_player: AudioStreamPlayer
var music_volume := 0.3


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.stream = load(MUSIC_PATH)
	add_child(music_player)
	
	set_volume(music_volume)
	music_player.play()


func set_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	
	if music_volume <= 0.0:
		music_player.volume_db = -80.0
	else:
		music_player.volume_db = linear_to_db(music_volume)
