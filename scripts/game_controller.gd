extends Node2D

@export var map_width: int = 4
@export var map_height: int = 4

@onready var map = $HUD/Map
@onready var scan_line = $HUD/UI/ScanDisplay/ScanSignals


func _ready() -> void:
	init_map()

func init_map():
	map.initialize(map_width, map_height)
	map.connect("scanned", display_scan)

func display_scan(results):
	scan_line.update_signals(results)
