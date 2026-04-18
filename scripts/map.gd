extends GridContainer
signal scanned
signal flagged

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
	print_debug("Clicked " + tile.name + ": (" + str(i) + ", " + str(j)+")")
	
func scan(tile, coords: Vector2i):
	var results = []
	# TODO get other tiles in scan radius
	var tiles = [coords] + get_neighbors(coords, scan_radius)
	for t in tiles:
		var scan_tile = grid[t.x][t.y]
		results.append(scan_tile.scan())
	emit_signal("scanned", results)

func flag(tile, coords):
	tile.flag()
	emit_signal("flagged", coords)

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
