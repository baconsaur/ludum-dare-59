extends GridContainer
signal scanned
signal flags_updated

@export var width: int = 4
@export var height: int = 4
@export var start_flags: int = 3
@export var scan_radius: int = 1
@export var noise_frequency: float = 3.5
@export var noise_jitter: float = 2.5
@export var max_noise_amplitude: float = 3.0
@export var base_signal_freq: float = 0.2
@export var max_signal_freq_offset: float = 0.65

var num_flags: int
var max_score: int = 0
var grid: Array = []
var tile_obj: PackedScene = preload("res://scenes/tile.tscn")

@onready var transition_sound = $TransitionSound

func _ready() -> void:
	randomize()

func initialize(map_data):
	width = map_data["width"]
	height = map_data["height"]
	start_flags = map_data["start_flags"]
	scan_radius = map_data["scan_radius"]

	num_flags = start_flags
	for row in grid:
		for tile in row:
			tile.queue_free()
	grid.clear()
	
	var noise_map = FastNoiseLite.new()
	# Test values with this: https://auburn.github.io/FastNoiseLite
	noise_map.noise_type = FastNoiseLite.TYPE_CELLULAR
	if OS.is_debug_build():
		noise_map.seed = 69420
	else:
		noise_map.seed = randi()
	noise_map.frequency = noise_frequency
	noise_map.cellular_distance_function = FastNoiseLite.DISTANCE_HYBRID
	noise_map.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_MUL
	noise_map.cellular_jitter = noise_jitter
	
	noise_map.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX
	noise_map.domain_warp_amplitude = 65
	noise_map.domain_warp_frequency = 0.05

	var tile_amplitudes = {}
	self.columns = width
	for i in range(height):
		var row = []
		grid.append(row)
		for j in range(width):
			var tile = tile_obj.instantiate()
			tile.pressed.connect(tile_action.bind(tile, i, j))
			tile.hovered.connect(tile_action.bind(tile, i, j))
			add_child(tile)
			var amplitude = abs(noise_map.get_noise_2d(i, j))
			if amplitude in tile_amplitudes:
				tile_amplitudes[amplitude].append(tile)
			else:
				tile_amplitudes[amplitude] = [tile]
			tile.init_tile(
				amplitude,
				randf_range(
					base_signal_freq,
					base_signal_freq + max_signal_freq_offset,
				),
			)
			row.append(tile)
	
	var amp_values = tile_amplitudes.keys()
	amp_values.sort()

	max_score = 0
	for i in range(len(amp_values)):
		var tiles = tile_amplitudes[amp_values[i]]
		for tile in tiles:
			tile.set_value(i, len(amp_values) - 1)
		if i >= len(amp_values) - num_flags:
			max_score += i

	emit_signal("flags_updated", num_flags)

func tile_action(tile, i, j):
	# TODO de-jank this if time allows
	if Input.is_action_just_released("flag"):
		flag(tile, Vector2i(i, j))
	else:
		scan(tile, Vector2i(i, j))
	
func scan(tile, coords: Vector2i):
	clear_scan()
	var results = []
	var neighbors = dedupe(get_neighbors(coords, scan_radius))
	for neighbor in neighbors:
		var target_tile = grid[neighbor.x][neighbor.y]
		var distance = neighbor.distance_to(coords)
		results.append(target_tile.scan(distance, scan_radius))
	emit_signal("scanned", results, scan_radius)

func clear_scan():
	for row in grid:
		for tile in row:
			tile.clear_scan()

func flag(tile, coords):
	if num_flags <= 0 and !tile.flagged:
		return
	var is_flagged = tile.flag()
	if is_flagged:
		num_flags -= 1
	else:
		num_flags += 1
	emit_signal("flags_updated", num_flags)

func get_neighbors(coords, radius):
	var neighbors = []
	var offsets = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, -1),
		Vector2i(0, 1),
	]
	if radius % 2:
		offsets += [
			Vector2i(1, 1),
			Vector2i(-1, 1),
			Vector2i(-1, -1),
			Vector2i(1, -1),
		]
		radius -= 1
	for offset in offsets:
		var neighbor_row = coords.x + offset.x
		var neighbor_col = coords.y + offset.y
		if neighbor_row >= 0 and neighbor_row < len(grid) and neighbor_col >= 0 and neighbor_col < len(grid[0]):
			neighbors.append(Vector2i(neighbor_row, neighbor_col))
	
	var current_neighbors = neighbors.duplicate()
	if radius > 0:
		for neighbor in current_neighbors:
			neighbors += get_neighbors(neighbor, radius - 1)
	return neighbors

func dedupe(array: Array) -> Array:
	var dict := {}
	for i in array:
		dict[i] = 1
	return dict.keys()

func reveal_score():
	for row in grid:
		for tile in row:
			tile.disabled = true
	var score = 0
	for row in grid:
		for tile in row:
			var tile_score = tile.score()
			score += tile_score
			
			var timeout = 0.01
			if tile_score > 0:
				timeout = 0.1
			await get_tree().create_timer(timeout).timeout
	return [score, max_score]
