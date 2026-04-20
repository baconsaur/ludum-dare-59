extends TextureButton
signal flag_resolved
signal hovered

@export var max_signal_decay: float = 0.8
@export var min_scan_opacity: float = 0.15
@export var value_color_range: Gradient
@export var sparkle_threshold: float = 0.8
@export var bronze_threshold: float = 0.55
@export var silver_threshold: float = 0.75
@export var gold_threshold: float = 0.85
@export var diamond_threshold: float = 0.93

var signal_amplitude = 0.0
var signal_frequency = 0.0
var flagged = false
var value = 0
var value_percent = 0
var rock_tex = preload("res://sprites/rock.png")
var bronze_tex = preload("res://sprites/bronze.png")
var silver_tex = preload("res://sprites/silver.png")
var gold_tex = preload("res://sprites/gold.png")
var diamond_tex = preload("res://sprites/diamond.png")

@onready var flag_sprite = $Flag
@onready var building_sprite = $Building
@onready var scan_effect = $ScanEffect
@onready var scan_target = $ScanTarget
@onready var value_label = $Value
@onready var sparkle_effect = $SparkleEffect
@onready var value_animation = $Value/AnimationPlayer
@onready var reward_sound = $RewardSound
@onready var build_sound = $BuildSound
@onready var flag_sound = $FlagSound

func init_tile(amplitude, frequency):
	flag_sprite.visible = false
	building_sprite.visible = false
	scan_effect.self_modulate.a = 0.0
	scan_target.visible = false
	signal_amplitude = amplitude
	signal_frequency = frequency

func set_value(rank, max_rank):
	# TODO make numbers more good?
	value = rank
	value_percent = float(rank) / float(max_rank)
	value_label.text = str(rank)

func scan(distance: float, radius: float):
	if distance <= 0: 
		scan_target.visible = true
	
	var decay = distance / radius
	scan_effect.self_modulate.a = lerp(0.4, min_scan_opacity, decay)

	return {
		"amplitude": signal_amplitude,
		"frequency": signal_frequency,
		"distance": distance,
	}

func clear_scan():
	scan_effect.self_modulate.a = 0.0
	scan_target.visible = false

func flag():
	flag_sound.play()
	flagged = !flagged
	flag_sprite.visible = flagged
	return flagged

func score():
	scan_effect.visible = false
	if flagged:
		build_sound.play()
		flag_sprite.self_modulate = Color("4052737d")
		value_animation.play("reward")
		if value_percent >= sparkle_threshold:
			reward_sound.play()
	
	#self_modulate = value_color_range.sample(value_percent)
	if value_percent >= gold_threshold:
		#sparkle_effect.self_modulate.a = remap(value_percent, sparkle_threshold, 1.0, 0.0, 1.0)
		sparkle_effect.emitting = true
		value_label.modulate = Color("#fdd179")
	
	if value_percent >= diamond_threshold:
		texture_normal = diamond_tex
	elif value_percent >= gold_threshold:
		texture_normal = gold_tex
	elif value_percent >= silver_threshold:
		texture_normal = silver_tex
	elif value_percent >= bronze_threshold:
		texture_normal = bronze_tex
	else:
		texture_normal = rock_tex
	
	clear_scan()
	if flagged:
		return value
	return 0

func _on_mouse_entered() -> void:
	emit_signal("hovered")
