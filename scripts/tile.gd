extends TextureButton
signal flag_resolved
signal hovered

@export var max_signal_decay: float = 0.8
@export var min_scan_opacity: float = 0.2
@export var value_color_range: Gradient
@export var sparkle_threshold: float = 0.8

var signal_amplitude = 0.0
var signal_frequency = 0.0
var flagged = false
var value = 0
var value_percent = 0

@onready var flag_sprite = $Flag
@onready var scan_effect = $ScanEffect
@onready var value_debug = $ValueDebug
@onready var sparkle_effect = $SparkleEffect

func init_tile(amplitude, frequency):
	sparkle_effect.visible = false
	flag_sprite.visible = false
	scan_effect.self_modulate.a = 0.0
	signal_amplitude = amplitude
	signal_frequency = frequency

func set_value(rank, max_rank):
	# TODO make numbers more good?
	value = rank
	value_percent = float(rank) / float(max_rank)
	
	value_debug.text = str(rank)
	#if OS.is_debug_build():
		#value_debug.visible = true

func scan(distance: float, radius: float):
	var decay = distance / radius
	scan_effect.self_modulate.a = lerp(0.9, min_scan_opacity, decay)

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
	#if OS.is_debug_build():
		#value_debug.visible = true
	
	self_modulate = value_color_range.sample(value_percent)
	if value_percent >= sparkle_threshold:
		sparkle_effect.self_modulate.a = remap(value_percent, sparkle_threshold, 1.0, 0.0, 1.0)
		sparkle_effect.visible = true
		sparkle_effect.emitting = true
	clear_scan()
	disabled = true
	if flagged:
		return value
	return 0

func _on_mouse_entered() -> void:
	emit_signal("hovered")
