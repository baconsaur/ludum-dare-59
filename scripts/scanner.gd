extends Line2D

@export var display_multiplier: float = 8.0
@export var max_amplitude: float = 12.5
@export var wave_color: Color = Color.LIME_GREEN
@export var ease_amount: float = 0.6

var offset = 0.0
var num_points = 150
var speed = 20.0
var step = 0.5
var falloff_distance = 0

var signals = []

func _process(delta):
	offset += delta * speed
	queue_redraw()

func _draw():
	var prev_point = Vector2(0, 0)
	
	for i in range(num_points):
		var x = i * step
		var y = 0
		for s in signals:
			var decayed_signal = lerp(
				s["amplitude"] * sin((x + offset) * s["frequency"]),
				0.0,
				ease(s["distance"] / falloff_distance, ease_amount),
			)
			y += decayed_signal
		y *= display_multiplier
		var current_point = Vector2(
			x,
			clamp(y, -max_amplitude, max_amplitude)
		)
		draw_line(prev_point, current_point, wave_color, 1.0)
		prev_point = current_point

func update_signals(scan_data, falloff):
	falloff_distance = falloff
	signals = scan_data
