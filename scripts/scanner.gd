extends Line2D

var amplitude = 0.0
var frequency = 0.2
var offset = 0.0
var num_points = 150
var speed = 20.0
var step = 0.5

var signals = []

func _process(delta):
	offset += delta * speed
	queue_redraw()

func _draw():
	var prev_point = Vector2(0, amplitude * sin(0))
	
	for i in range(num_points):
		var x = i * step
		var y = 0
		for s in signals:
			y += s["amplitude"] * sin((x + offset) * s["frequency"])
		var current_point = Vector2(x, clamp(y, -30.0, 30.0))
		
		draw_line(prev_point, current_point, Color.LIME_GREEN, 1.0)
		prev_point = current_point

func update_signals(scan_data):
	signals = scan_data
