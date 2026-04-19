extends TextureButton

@export var max_signal_decay: float = 0.8
@export var min_scan_opacity: float = 0.2

var signal_amplitude = 0.0
var signal_frequency = 0.0
var flagged = false

@onready var flag_sprite = $Flag
@onready var scan_effect = $ScanEffect

func init_tile(amplitude, frequency):
	flag_sprite.visible = false
	scan_effect.self_modulate.a = 0.0
	signal_amplitude = amplitude
	signal_frequency = frequency
	if OS.is_debug_build():
		var debug_magnitude = signal_amplitude
		modulate = Color(debug_magnitude, 0.5, 0.5)

func scan(distance: float, radius: float):
	var decay = distance / radius
	scan_effect.self_modulate.a = lerp(1.0, min_scan_opacity, decay)

	return {
		"amplitude": signal_amplitude,
		"frequency": signal_frequency,
		"distance": distance,
	}

func clear_scan():
	scan_effect.self_modulate.a = 0.0
	

func flag():
	flagged = !flagged
	flag_sprite.visible = flagged
	return flagged
