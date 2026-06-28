extends Node2D

@export var bullet_scene: PackedScene

@onready var muzzle: Marker2D = $Muzzle

@export var pistol_sound: AudioStream
@export var machine_gun_sound: AudioStream
@export var shotgun_sound: AudioStream
@export var pistol_reload_sound: AudioStream
@export var machine_gun_reload_sound: AudioStream
@export var shotgun_reload_sound: AudioStream

@onready var fire_sound: AudioStreamPlayer2D = $FireSound
@onready var reload_sound: AudioStreamPlayer2D = $ReloadSound

@export var gamepad_id: int = 0
@export var stick_deadzone: float = 0.25

var gun_type: String = "pistol"
var weapon_index: int = 0
var weapon_order: Array[String] = [
	"pistol",
	"machine gun",
	"shotgun"
]

var fire_cooldown: float = 0.0
var fire_rate: float = 0.25
var bullet_damage: int = 1
var bullets_per_shot: int = 1
var shot_spread: float = 0.0

var magazine_size: int = 8
var ammo_in_mag: int = 8

var reload_time: float = 1.0
var reload_timer: float = 0.0
var is_reloading: bool = false

var ammo_by_gun := {
	"pistol": 8,
	"machine gun": 30,
	"shotgun": 5
}

func _process(delta: float) -> void:
	update_aim()

	fire_cooldown -= delta

	if is_reloading:
		reload_timer -= delta

		if reload_timer <= 0.0:
			finish_reload()

		return

	if Input.is_action_just_pressed("reload"):
		start_reload()
		return

	if Input.is_action_pressed("shoot") and fire_cooldown <= 0.0:
		if ammo_in_mag <= 0:
			start_reload()
			return

		shoot()
		ammo_in_mag -= 1
		ammo_by_gun[gun_type] = ammo_in_mag
		fire_cooldown = fire_rate


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			equip_pistol()
			weapon_index = 0

		if event.keycode == KEY_2:
			equip_machine_gun()
			weapon_index = 1

		if event.keycode == KEY_3:
			equip_shotgun()
			weapon_index = 2

	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			cycle_weapon()

func cycle_weapon() -> void:
	weapon_index += 1

	if weapon_index >= weapon_order.size():
		weapon_index = 0

	var next_weapon: String = weapon_order[weapon_index]

	if next_weapon == "pistol":
		equip_pistol()
	elif next_weapon == "machine gun":
		equip_machine_gun()
	elif next_weapon == "shotgun":
		equip_shotgun()


# use controller right axis for aiming, otherwise use mouse
func update_aim() -> void:
	var stick_vector := Vector2(
		Input.get_joy_axis(gamepad_id, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(gamepad_id, JOY_AXIS_RIGHT_Y)
	)

	if stick_vector.length() > stick_deadzone:
		global_rotation = stick_vector.angle()
	else:
		look_at(get_global_mouse_position())

func shoot() -> void:
	if bullet_scene == null:
		return

	play_fire_sound()

	for i in range(bullets_per_shot):
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)

		var angle_offset: float = 0.0

		if bullets_per_shot > 1:
			var spread_step: float = shot_spread / float(bullets_per_shot - 1)
			angle_offset = -shot_spread * 0.5 + spread_step * i

		var shot_rotation: float = global_rotation + angle_offset

		bullet.global_position = muzzle.global_position
		bullet.global_rotation = shot_rotation
		bullet.direction = Vector2.RIGHT.rotated(shot_rotation)
		bullet.damage = bullet_damage

func start_reload() -> void:
	if is_reloading:
		return

	if ammo_in_mag >= magazine_size:
		return

	is_reloading = true
	reload_timer = reload_time
	play_reload_sound()


func finish_reload() -> void:
	is_reloading = false
	ammo_in_mag = magazine_size
	ammo_by_gun[gun_type] = ammo_in_mag
	
	if reload_sound != null:
		reload_sound.stop()


func equip_pistol() -> void:
	gun_type = "pistol"
	fire_rate = 0.25
	bullet_damage = 1
	bullets_per_shot = 1
	shot_spread = 0.0

	magazine_size = 8
	reload_time = 0.9
	ammo_in_mag = ammo_by_gun[gun_type]
	
	#stop reload sound when switching weapons
	is_reloading = false
	if reload_sound != null:
		reload_sound.stop()


func equip_machine_gun() -> void:
	gun_type = "machine gun"
	fire_rate = 0.08
	bullet_damage = 1
	bullets_per_shot = 1
	shot_spread = 0.0

	magazine_size = 30
	reload_time = 1.6
	ammo_in_mag = ammo_by_gun[gun_type]
	
	is_reloading = false
	if reload_sound != null:
		reload_sound.stop()


func equip_shotgun() -> void:
	gun_type = "shotgun"
	fire_rate = 0.6
	bullet_damage = 1
	bullets_per_shot = 5
	shot_spread = 0.5

	magazine_size = 5
	reload_time = 1.3
	ammo_in_mag = ammo_by_gun[gun_type]
	
	is_reloading = false
	if reload_sound != null:
		reload_sound.stop()


func get_gun_type() -> String:
	return gun_type

func get_ammo_text() -> String:
	if is_reloading:
		return "Reloading %.1f" % reload_timer

	return "%d/%d" % [ammo_in_mag, magazine_size]

func play_fire_sound() -> void:
	var sound: AudioStream = null

	if gun_type == "pistol":
		sound = pistol_sound
	elif gun_type == "machine gun":
		sound = machine_gun_sound
	elif gun_type == "shotgun":
		sound = shotgun_sound

	if sound == null:
		return

	# create temp audio players for polyphony
	var player := AudioStreamPlayer2D.new()
	add_child(player)
	player.stream = sound
	player.global_position = global_position
	player.finished.connect(player.queue_free)
	player.play()


func play_reload_sound() -> void:
	if reload_sound == null:
		return

	if gun_type == "pistol":
		reload_sound.stream = pistol_reload_sound
	elif gun_type == "machine gun":
		reload_sound.stream = machine_gun_reload_sound
	elif gun_type == "shotgun":
		reload_sound.stream = shotgun_reload_sound

	if reload_sound.stream != null:
		reload_sound.stop()
		reload_sound.play()
