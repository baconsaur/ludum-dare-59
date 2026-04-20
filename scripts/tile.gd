extends TextureButton
signal flag_resolved

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

func score():
	clear_scan()
	disabled = true
	self_modulate = Color(signal_amplitude, 0.5, 0.5)
	if flagged:
		# TODO use something else for scoring?
		return signal_amplitude
	return 0
