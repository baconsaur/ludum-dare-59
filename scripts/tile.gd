extends TextureButton

@export var max_amplitude = 5.0

var signal_amplitude = 0.0
var signal_frequency = 0.0
var flagged = false

@onready var flag_sprite = $Flag
@onready var scan_effect = $ScanEffect

func _ready() -> void:
	init_tile()

func init_tile():
	flag_sprite.visible = false
	scan_effect.self_modulate.a = 0.0
	randomize()
	signal_amplitude = randf_range(0, max_amplitude)
	signal_frequency = randf_range(0.4, 0.6)
	if OS.is_debug_build():
		var debug_magnitude = abs(signal_amplitude / max_amplitude)
		modulate = Color(debug_magnitude, 0.5, 0.5)

func scan(distance: float = 0.0):
	scan_effect.self_modulate.a = 0.8 - distance * 0.5

	return {
		"amplitude": signal_amplitude if distance == 0 else signal_amplitude * 0.5,
		"frequency": signal_frequency
	}

func clear_scan():
	scan_effect.self_modulate.a = 0.0
	

func flag():
	flagged = !flagged
	flag_sprite.visible = flagged
	return flagged
