extends AudioStreamPlayer

const MIC_BUS_NAME: String = "MicInput"
const PRINT_INTERVAL: float = 0.15
const SILENCE_DB: float = -30.0
const LOUD_DB: float = -15.0
const VOLUME_CURVE: float = 5

var capture: AudioEffectCapture
var mic_input_db: float = -80.0
var print_timer: float = 0.0
var is_talking: bool = false
var volume_amount: float = 0.0

# set mic
func _ready() -> void:
	var bus_index: int = AudioServer.get_bus_index(MIC_BUS_NAME)
	capture = AudioServer.get_bus_effect(bus_index, 0) as AudioEffectCapture
	print("Listening for microphone volume...")

#print whether silence or sound is detected and at what volume in dB
func _process(delta: float) -> void:
	read_microphone_volume()

	is_talking = mic_input_db >= SILENCE_DB

	var raw_volume: float = clampf(inverse_lerp(SILENCE_DB, LOUD_DB, mic_input_db), 0.0, 1.0)
	volume_amount = pow(raw_volume, VOLUME_CURVE)

	print_timer -= delta

	if print_timer <= 0.0:
		print_timer = PRINT_INTERVAL
		print_volume()

#https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html
#currently dependent on frame rate since it's tied to func _process()
#could reduce jitter by increasing the audio analysis duration
#i.e. for 125 ms instead of samples = sample_rate * ms / 1000
# samples = 48000 Hz * 125 ms / 1000
# samples = 6000

func read_microphone_volume() -> void:
	var frames_available: int = capture.get_frames_available()

	if frames_available <= 0:
		return

	#stores mono mic input as vector2 for some reason 
	var frames: PackedVector2Array = capture.get_buffer(frames_available)
	var total: float = 0.0

	#so combine left frame.x and right frame.y channels into mono
	for frame: Vector2 in frames:
		var mono: float = (frame.x + frame.y) * 0.5
		total += mono * mono

	#measure average loudness of changing waveform using RMS
	#then convert to dB
	var rms: float = sqrt(total / float(frames.size()))
	mic_input_db = linear_to_db(maxf(rms, 0.000001))


func print_volume() -> void:
	var rounded_db: float = snapped(mic_input_db, 0.1)

	if mic_input_db < SILENCE_DB:
		print("silence | volume: ", rounded_db, " dB ", volume_amount)
	else:
		print("sound detected | volume: ", rounded_db, " dB ", volume_amount)
