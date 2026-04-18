extends Node2D

@export var map_width: int = 4
@export var map_height: int = 4

@onready var map = $HUD/Map
@onready var scan_results = $HUD/UI/ScanResults


func _ready() -> void:
	init_map()

func init_map():
	map.initialize(map_width, map_height)
	map.connect("scanned", display_scan)
	map.connect("flagged", set_flag)

func display_scan(results):
	print_debug(results)

func set_flag(coords):
	print_debug(coords)
