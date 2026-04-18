extends GridContainer

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
	var tiles = [tile]
	if Input.is_action_just_released("flag"):
		flag(tiles)
	elif Input.is_action_just_released("scan"):
		# TODO get other tiles in scan radius
		scan(tiles)
	print_debug("Clicked " + tile.name + ": (" + str(i) + ", " + str(j)+")")
	
func scan(tiles):
	print_debug("scan")

func flag(tiles):
	print_debug("flag")
