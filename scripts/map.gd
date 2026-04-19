extends GridContainer
signal scanned
signal flagged
signal unflagged

@export var num_flags: int = 3
@export var scan_radius: int = 1

var grid: Array = []
var tile_obj: PackedScene = preload("res://scenes/tile.tscn")


func initialize(width: int, height: int):
	columns = width
	grid.clear()
	for i in range(height):
		var row = []
		grid.append(row)
		for j in range(width):
			var tile = tile_obj.instantiate()
			tile.pressed.connect(tile_action.bind(tile, i, j))
			add_child(tile)
			row.append(tile)

func tile_action(tile, i, j):
	# TODO de-jank this if time allows
	if Input.is_action_just_released("flag"):
		flag(tile, Vector2i(i, j))
	elif Input.is_action_just_released("scan"):
		scan(tile, Vector2i(i, j))
	
func scan(tile, coords: Vector2i):
	clear_scan()
	var results = [tile.scan()]
	var neighbors = get_neighbors(coords, scan_radius)
	for neighbor in neighbors:
		var target_tile = grid[neighbor.x][neighbor.y]
		results.append(target_tile.scan(1))
	emit_signal("scanned", results)

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
	print_debug(num_flags)

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
